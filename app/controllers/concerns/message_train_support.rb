# MessageTrain support
module MessageTrainSupport
  extend ActiveSupport::Concern
  included do
    # Last in first out
    prepend_before_filter :load_collective_boxes,
                          :load_box,
                          :load_collective,
                          :load_division,
                          :load_box_user,
                          unless: :devise_controller?
    before_filter :load_objects
    before_action :set_locale

    helper MessageTrain::ApplicationHelper
    helper MessageTrain::BoxesHelper
    helper MessageTrain::CollectivesHelper
    helper MessageTrain::ConversationsHelper
    helper MessageTrain::MessagesHelper
    helper MessageTrain::AttachmentsHelper

    rescue_from ActiveRecord::RecordNotFound do
      render '404', status: :not_found
    end
  end

  protected

  def anonymous
    @anonymous = true
    MessageTrain.configuration.user_model.constantize.new
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def load_box_user
    @box_user = send(
      MessageTrain.configuration.current_user_method
    ) || anonymous
  end

  def load_division
    @division = (params[:division] || params[:box_division] || 'in').to_sym
  end

  def load_collective
    return unless params[:collective_id].present?

    collective_table, collective_id = params[:collective_id].split(':')
    collective_class_name = MessageTrain.configuration.recipient_tables[
      collective_table.to_sym
    ]
    collective_model = collective_class_name.constantize
    slug_column = MessageTrain.configuration
                              .slug_columns[collective_table.to_sym] || :slug
    @collective = collective_model.find_by!(slug_column => collective_id)

    unless @collective.allows_receiving_by?(
      @box_user
    ) || @collective.allows_sending_by?(
      @box_user
    )
      flash[:error] = :access_to_that_box_denied.l
      redirect_to main_app.root_url
      return
    end

    case @division
    when :in, :ignored
      unless @collective.allows_receiving_by? @box_user
        flash[:error] = :access_to_that_box_denied.l
        redirect_to message_train.collective_box_url(
          @collective.path_part,
          :sent
        )
      end
    when :sent, :drafts
      unless @collective.allows_sending_by? @box_user
        flash[:error] = :access_to_that_box_denied.l
        redirect_to message_train.collective_box_url(
          @collective.path_part,
          :in
        )
      end
    end
  end

  def load_box
    @box = if !@collective.nil?
             @collective.box(@division, @box_user)
           else
             @box_user.box(@division)
           end
  end

  def load_collective_boxes
    @collective_boxes = @box_user.collective_boxes(@division, @box_user)
  end

  def load_objects
    @objects = {}
    @objects['conversations'] = {}
    @objects['messages'] = {}

    return unless params[:objects].present?
    params[:objects].each do |type, list|
      list.each do |key, list_item|
        @objects[type][key.to_s] = list_item.to_i
      end
    end
  end

  def respond_to_marking
    if !@box.errors.all.empty?
      respond_to do |format|
        format.html do
          flash[:error] = @box.message
          show
        end
        format.json { render :results, status: :unprocessable_entity }
      end
    else
      respond_to do |format|
        format.html do
          if @box.results.all.empty?
            flash[:alert] = @box.message
          else
            flash[:notice] = @box.message
          end
          show
        end
        format.json { render :results, status: :accepted }
      end
    end
  end
end

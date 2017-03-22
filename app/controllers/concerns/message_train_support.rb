# MessageTrain support
module MessageTrainSupport
  extend ActiveSupport::Concern
  included do
    # Last in first out
    prepend_before_action :load_collective_boxes,
                          :load_box,
                          :load_collective,
                          :load_division,
                          :load_box_user,
                          unless: :devise_controller?
    before_action :load_objects
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

  def redirect_to_sign_in
    flash[:error] = :you_must_sign_in_or_sign_up_to_continue.l
    redirect_to MessageTrain.configuration.user_sign_in_path
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
    @box_user = send(MessageTrain.configuration.current_user_method)
    @box_user ||= anonymous
  end

  def load_division
    @division = (params[:division] || params[:box_division] || 'in').to_sym
  end

  def load_collective
    return unless params[:collective_id].present?
    collective_table, collective_id = params[:collective_id].split(':')
    model = get_collective_model(collective_table)
    @collective = model.find_by!(model.slug_column => collective_id)
    authorize_collective(@collective, @division)
  end

  def get_collective_model(table)
    MessageTrain.configuration.recipient_tables[table.to_sym].constantize
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
    @objects = { 'conversations' => {}, 'messages' => {} }
    return unless params[:objects].present?
    params[:objects].each do |type, list|
      list.each do |key, list_item|
        @objects[type][key.to_s] = list_item.to_i
      end
    end
  end

  def respond_to_marking
    @box.errors.any? ? marking_error : marking_success
  end

  def marking_error
    respond_to do |format|
      format.html do
        flash[:error] = @box.message
        show
      end
      format.json { render :results, status: :unprocessable_entity }
    end
  end

  def marking_success
    respond_to do |format|
      format.html do
        flash_type = @box.results.any? ? :notice : :alert
        flash[flash_type] = @box.message
        show
      end
      format.json { render :results, status: :accepted }
    end
  end
end

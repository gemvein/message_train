module MessageTrain
  class ApplicationController < ::ApplicationController

    # Last in first out
    prepend_before_filter :load_collective_boxes,
                          :load_box,
                          :load_collective,
                          :load_division,
                          :load_box_user

    before_filter :load_objects
    before_action :set_locale
    helper BoxesHelper
    helper CollectivesHelper
    helper ConversationsHelper
    helper MessagesHelper

    rescue_from ActiveRecord::RecordNotFound do
      render '404', status: :not_found
    end

    rescue_from ActionController::RoutingError do
      redirect_to url_for(MessageTrain.configuration.user_sign_in_path), flash: { notice: :you_must_sign_in_or_sign_up_to_continue.l }
    end

    protected
      def set_locale
        I18n.locale = params[:locale] || I18n.default_locale
      end

      def load_box_user
        @box_user = send(MessageTrain.configuration.current_user_method)
      end

      def load_division
        @division = (params[:division] || params[:box_division]).to_sym
      end

      def load_collective
        if params[:collective_id].present?
          collective_table, collective_id = params[:collective_id].split(':')
          collective_class_name = MessageTrain.configuration.recipient_tables[collective_table.to_sym]
          collective_model = collective_class_name.constantize
          slug_column = MessageTrain.configuration.slug_columns[collective_table.to_sym]
          @collective = collective_model.find_by(slug_column => collective_id)

          unless @collective.allows_receiving_by?(@box_user) || @collective.allows_sending_by?(@box_user)
            flash[:error] = :access_to_that_box_denied.l
            redirect_to root_url
          end

          case @division
          when :in, :ignored
            unless @collective.allows_receiving_by? @box_user
              flash[:error] = :access_to_that_box_denied.l
              redirect_to message_train.collective_box_path(@collective.path_part, :sent)
            end
          when :sent, :drafts
            unless @collective.allows_sending_by? @box_user
              flash[:error] = :access_to_that_box_denied.l
              redirect_to message_train.collective_box_path(@collective.path_part, :in)
            end
          else
            # do nothing
          end
        end
      end

      def load_box
        if !@collective.nil?
          @box = @collective.box(@division, @box_user)
        else
          @box = @box_user.box(@division)
        end
      end

      def load_collective_boxes
        @collective_boxes = @box_user.collective_boxes(@division, @box_user)
      end

      def load_objects
        @objects = {}
        @objects['conversations'] = {}
        @objects['messages'] = {}
        if params[:objects].present?
          params[:objects].each do |type, list|
            list.each do |key, list_item|
              @objects[type][key.to_s] = list_item.to_i
            end
          end
        end
      end

      def respond_to_marking
        if !@box.errors.all.empty?
          respond_to do |format|
            format.html {
              flash[:error] = @box.message
              show
            }
            format.json { render :results, status: :unprocessable_entity }
          end
        else
          respond_to do |format|
            format.html {
              if @box.results.all.empty?
                flash[:alert] = @box.message
              else
                flash[:notice] = @box.message
              end
              show
            }
            format.json { render :results, status: :accepted }
          end
        end
      end
  end
end

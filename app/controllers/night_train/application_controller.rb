module NightTrain
  class ApplicationController < ::ApplicationController
    helper BoxesHelper
    helper ConversationsHelper
    before_filter :load_box
    before_filter :load_objects
    before_action :set_locale

    rescue_from ActiveRecord::RecordNotFound do
      render '404', status: :not_found
    end

    rescue_from ActionController::RoutingError do
      redirect_to url_for(NightTrain.configuration.user_sign_in_path), flash: { notice: :you_must_sign_in_or_sign_up_to_continue.l }
    end

    private
      def set_locale
        I18n.locale = params[:locale] || I18n.default_locale
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

      def load_box
        @box = send(NightTrain.configuration.current_user_method).box(params[:box_division].to_sym)
      end
  end
end

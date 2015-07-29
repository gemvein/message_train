module NightTrain
  class ApplicationController < ::ApplicationController
    before_filter :load_box
    before_action :set_locale

    private
      def set_locale
        I18n.locale = params[:locale] || I18n.default_locale
      end

      def load_box
        @box = send(NightTrain.configuration.current_user_method).box(params[:division].to_sym)
      end
  end
end

module NightTrain
  class MessagesController < NightTrain::ApplicationController
    before_filter :load_message

    # GET /box/in/messages/1
    def show
      respond_to do |format|
        format.json { render :show }
      end
    end

    # PATCH/PUT /box/in/messages/1
    def update
      if params[:mark_to_set].present?
        @box.mark params[:mark_to_set], @message
      end
      respond_to_marking
    end

    private

      def load_message
        @message = @box.find_message(params[:id])
      end
  end
end

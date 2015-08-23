module MessageTrain
  class ConversationsController < MessageTrain::ApplicationController
    before_filter :load_conversation
    after_filter :mark_as_read

    # GET /box/in/conversations/1
    def show
      @messages = @conversation.messages.page(params[:page])
      render :show
    end

    # PATCH/PUT /box/in/conversations/1
    def update
      if params[:mark_to_set].present? && @objects.present?
        @box.mark params[:mark_to_set], @objects
      end
      respond_to_marking
    end

    # DELETE /box/in/conversations/1
    def destroy
      if ['ignore', 'unignore'].include? params[:mark_to_set]
        @box.send(params[:mark_to_set], @conversation)
      end
      respond_to_marking
    end

    private

      def load_conversation
        @conversation = @box.find_conversation(params[:id])
      end

      def mark_as_read
        @box.mark :read, conversations: @conversation
      end
  end
end

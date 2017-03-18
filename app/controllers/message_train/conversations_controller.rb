module MessageTrain
  # Conversations controller
  class ConversationsController < MessageTrain::ApplicationController
    before_action :load_conversation
    after_action :mark_as_read

    # GET /box/:division/conversations/:id
    def show
      @messages = @conversation.messages.page(params[:page])
      render :show
      @box.mark :read, @messages
    end

    # PATCH/PUT /box/:division/conversations/:id
    def update
      if params[:mark_to_set].present? && @objects.present?
        @box.mark params[:mark_to_set], @objects
      end
      respond_to_marking
    end

    # DELETE /box/:division/conversations/:id
    def destroy
      if %w(ignore unignore).include? params[:mark_to_set]
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

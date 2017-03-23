module MessageTrain
  # Messages controller
  class MessagesController < MessageTrain::ApplicationController
    before_action :load_message, only: [:show, :edit, :update]

    # GET /box/in/messages/1
    def show
      respond_to do |format|
        format.json { render :show }
      end
    end

    # GET /box/:division/messages/new
    def new
      if params[:conversation_id]
        @conversation = @box.find_conversation params[:conversation_id]
        @message = @conversation.messages.new_reply(box: @box)
      else
        @message = MessageTrain::Message.new(box: @box)
      end
    end

    # GET /box/:division/messages/:id/edit
    def edit
      !@message.draft && raise(ActiveRecord::RecordNotFound)
    end

    # POST /box/:division/messages
    def create
      @message = @box.send_message(message_params)
      return create_error if @box.errors.any?
      if @message.draft
        redirect_to message_train.box_path(:drafts), alert: @box.message
      else
        redirect_to message_train.box_path(:sent), notice: @box.message
      end
    end

    # PATCH/PUT /box/:division/messages/:id
    def update
      @box.update_message(@message, message_params)

      return update_error if @box.errors.any?

      if @message.draft
        redirect_draft
      else
        redirect_ready
      end
    end

    private

    def redirect_draft
      redirect_to(
        message_train.box_conversation_url(@box, @message.conversation),
        alert: @box.message
      )
    end

    def redirect_ready
      redirect_to(
        message_train.box_path(:sent),
        notice: @box.message
      )
    end

    def update_error
      flash[:error] = @box.message
      render :edit
      false
    end

    def create_error
      flash[:error] = @box.message
      render :new
      false
    end

    def load_message
      @message = @box.find_message(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list
    # through.
    def message_params
      permitted = params.require(:message).permit(
        :conversation_id,
        :subject,
        :body,
        :draft,
        attachments_attributes: [:id, :attachment, :_destroy],
        recipients_to_save: MessageTrain.configuration.recipient_tables.keys
      )
      permitted['draft'] = (permitted['draft'] == :save_as_draft.l)
      permitted
    end
  end
end

module MessageTrain
  class MessagesController < MessageTrain::ApplicationController
    before_filter :load_message, only: [:show, :edit, :update]

    # GET /box/in/messages/1
    def show
      respond_to do |format|
        format.json { render :show }
      end
    end

    # GET /box/in/messages/new
    def new
      @message = @box.new_message(conversation_id: params[:conversation_id])
    end

    # GET /box/in/messages/1/edit
    def edit
      unless @message.draft
        raise ActiveRecord::RecordNotFound
      end
    end

    # POST /box/in/messages
    def create
      @message = @box.send_message(message_params)
      if @box.errors.all.empty?
        if @message.draft
          redirect_to message_train.box_path(:drafts), alert: :message_saved_as_draft.l
        else
          redirect_to message_train.box_path(:sent), notice: :message_sent.l
        end
      else
        flash[:error] = @box.message
        render :new
      end
    end

    # PATCH/PUT /box/in/messages/1
    def update
      unless @message.draft
        raise ActiveRecord::RecordNotFound
      end
      @box.update_message(@message, message_params)
      if @box.errors.all.empty?
        if @message.draft
          redirect_to message_train.box_conversation_url(@box, @message.conversation), alert: :message_saved_as_draft.l
        else
          redirect_to message_train.box_path(:sent), notice: :message_sent.l
        end
      else
        flash[:error] = @box.message
        render :edit
      end
    end

  private
    def load_message
      @message = @box.find_message(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(
          :conversation_id,
          :subject,
          :body,
          :draft,
          attachments: [:attachment],
          recipients_to_save: MessageTrain.configuration.recipient_tables
      )
    end
  end
end
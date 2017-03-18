module MessageTrain
  # Participants controller
  class ParticipantsController < MessageTrain::ApplicationController
    before_action :load_participants
    before_action :load_participant, only: :show

    # GET /box/:division/participants/:model.json
    def index
      respond_to do |format|
        format.json { render :index }
      end
    end

    # GET /box/:division/participants/:model/:id.json
    def show
      respond_to do |format|
        format.json { render :show }
      end
    end

    private

    def load_participants
      # TODO: Change this to raise some more logical error
      params[:model].empty? && raise(ActiveRecord::RecordNotFound)
      model_sym = params[:model].to_sym
      model = MessageTrain.configuration.recipient_tables[model_sym].constantize
      current_participant = send(MessageTrain.configuration.current_user_method)
      @participants = model.message_train_address_book(current_participant)

      return unless params[:query].present?
      field_name = MessageTrain.configuration.slug_columns[model_sym]
      pattern = Regexp.union('\\', '%', '_')
      query = params[:query].gsub(pattern) { |x| ['\\', x].join }
      @participants = @participants.where(
        "#{field_name} LIKE ?",
        "#{query}%"
      )
    end

    def load_participant
      @participant = @participants.find(params[:id])
    end
  end
end

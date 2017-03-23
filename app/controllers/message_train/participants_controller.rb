module MessageTrain
  # Participants controller
  class ParticipantsController < MessageTrain::ApplicationController
    before_action :load_model
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

    def load_model
      params[:model].empty? && raise(ActiveRecord::RecordNotFound)
      @model = MessageTrain.configuration
                           .recipient_tables[params[:model].to_sym]
                           .constantize
    end

    def load_participants
      current_participant = send(MessageTrain.configuration.current_user_method)
      @participants = @model.message_train_address_book(current_participant)
      @participants = @participants.where_slug_starts_with(params[:query])
    end

    def load_participant
      @participant = @participants.find(params[:id])
    end
  end
end

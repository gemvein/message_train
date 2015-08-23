module MessageTrain
  class ParticipantsController < MessageTrain::ApplicationController
    before_filter :load_participants
    before_filter :load_participant, only: :show

    # GET /box/in/participants
    def index
      respond_to do |format|
        format.json { render :index }
      end
    end

    # GET /box/in/participants/1
    def show
      respond_to do |format|
        format.json { render :show }
      end
    end

    private

      def load_participants
        current_participant = send(MessageTrain.configuration.current_user_method)
        method = MessageTrain.configuration.address_book_method
        if current_participant.respond_to? method
          @participants = current_participant.send(method)
        else
          @participants = current_participant.class.all
        end
      end

      def load_participant
        @participant = @participants.find(params[:id])
      end
  end
end

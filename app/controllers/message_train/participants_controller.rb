module MessageTrain
  class ParticipantsController < MessageTrain::ApplicationController
    before_filter :load_participants
    before_filter :load_participant, only: :show

    # GET /box/:division/participants/:model
    def index
      respond_to do |format|
        format.json { render :index }
      end
    end

    # GET /box/:division/participants/:model/:id
    def show
      respond_to do |format|
        format.json { render :show }
      end
    end

    private

      def load_participants
        if params[:model].empty?
          raise ActiveRecord::RecordNotFound
        end
        model_sym = params[:model].to_sym
        model = MessageTrain.configuration.recipient_tables[model_sym].constantize
        method = MessageTrain.configuration.address_book_methods[model_sym]
        fallback_method = MessageTrain.configuration.address_book_method
        current_participant = send(MessageTrain.configuration.current_user_method)
        if !method.nil? && model.respond_to?(method)
          @participants = model.send(method, current_participant)
        elsif !fallback_method.nil? && model.respond_to?(fallback_method)
          @participants = model.send(fallback_method, current_participant)
        else
          @participants = model.all
        end
      end

      def load_participant
        @participant = @participants.find(params[:id])
      end
  end
end

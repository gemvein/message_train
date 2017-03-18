module MessageTrain
  # Unsubscribes controller
  class UnsubscribesController < MessageTrain::ApplicationController
    # GET /unsubscribes
    def index
      @subscriptions = @box_user.subscriptions
    end

    # POST /unsubscribes
    def create
      if params[:all]
        unsubscribe_from_all
        return
      end
      unsub = unsubscribe_params
      model = unsub[:from_type].constantize

      @from = model.find(unsub[:from_id])
      unless @from == @box_user || @from.allows_receiving_by?(@box_user)
        flash[:error] = :you_are_not_in_that_collective_type.l(
          collective_type: model.name
        )
        raise ActiveRecord::RecordNotFound
      end

      @unsubscribe = @box_user.unsubscribe_from(@from)
      unless @unsubscribe.errors.empty?
        flash[:error] = @unsubscribe.errors.full_messages.to_sentence
        redirect_to message_train.unsubscribes_url
        return
      end

      if @from == @box_user
        flash[:notice] = :unsubscribe_message.l
      else
        name_column = MessageTrain.configuration.name_columns[
          @from.class.table_name.to_sym
        ]
        collective_name = @from.send(name_column)
        collective_type = @from.class.name
        flash[:notice] = :collective_unsubscribe_message.l(
          collective_name: collective_name,
          collective_type: collective_type
        )
      end
      redirect_to message_train.unsubscribes_url
    end

    # DELETE /unsubscribes/:id
    def destroy
      if params[:all]
        @unsubscribe = @box_user.unsubscribes.where(from: nil).destroy_all
        flash[:notice] = :unsubscribe_all_removed_message.l
      else
        @unsubscribe = @box_user.unsubscribes.find(params[:id])
        @from = @unsubscribe.from
        if @from == @box_user
          message = :unsubscribe_removed_message.l
        else
          name_column = MessageTrain.configuration.name_columns[
            @unsubscribe.from.class.table_name.to_sym
          ]
          collective_name = @unsubscribe.from.send(name_column)
          collective_type = @unsubscribe.from_type
          message = :collective_unsubscribe_removed_message.l(
            collective_name: collective_name,
            collective_type: collective_type
          )
        end
        @unsubscribe.destroy
        flash[:notice] = message
      end
      redirect_to message_train.unsubscribes_url
    end

    private

    # Never trust parameters from the scary internet, only allow the white list
    # through.
    def unsubscribe_params
      params.require(:unsubscribe).permit(:from_type, :from_id)
    end

    def unsubscribe_from_all
      @unsubscribe = @box_user.unsubscribe_from(nil)
      if @unsubscribe.errors.empty?
        flash[:notice] = :unsubscribe_from_all_message.l
      else
        flash[:error] = @unsubscribe.errors.full_messages.to_sentence
      end
      redirect_to message_train.unsubscribes_url
    end
  end
end

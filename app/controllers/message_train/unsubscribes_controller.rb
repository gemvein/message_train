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
      unsubscribe_from_one || return
      flash[:notice] = if @from == @box_user
                         unsubscribe_message_from_box_user
                       else
                         unsubscribe_message_from_other
                       end
      redirect_to message_train.unsubscribes_url
    end

    # DELETE /unsubscribes/:id
    def destroy
      flash[:notice] = params[:all] ? destroy_all : destroy_one
      redirect_to message_train.unsubscribes_url
    end

    private

    def destroy_all
      @unsubscribe = @box_user.unsubscribes.where(from: nil).destroy_all
      :unsubscribe_all_removed_message.l
    end

    def destroy_one
      @unsubscribe = @box_user.unsubscribes.find(params[:id])
      @from = @unsubscribe.from
      @unsubscribe.destroy
      if @from == @box_user
        destroy_message_through_self
      else
        destroy_message_through_other
      end
    end

    def destroy_message_through_self
      :unsubscribe_removed_message.l
    end

    def destroy_message_through_other
      name_column = MessageTrain.configuration.name_columns[
        @unsubscribe.from.class.table_name.to_sym
      ]
      collective_name = @unsubscribe.from.send(name_column)
      collective_type = @unsubscribe.from_type
      :collective_unsubscribe_removed_message.l(
        collective_name: collective_name,
        collective_type: collective_type
      )
    end

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

    def unsubscribe_from_one
      unsub = unsubscribe_params
      model = unsub[:from_type].constantize

      @from = model.find(unsub[:from_id])
      authorize_unsubscribe

      @unsubscribe = @box_user.unsubscribe_from(@from)

      if @unsubscribe.errors.any?
        unsubscribe_errors
      else
        true
      end
    end

    def authorize_unsubscribe
      return true if @from.allows_receiving_by?(@box_user)
      flash[:error] = :you_are_not_in_that_collective_type.l(
        collective_type: @from.class.name
      )
      raise ActiveRecord::RecordNotFound
    end

    def unsubscribe_errors
      flash[:error] = @unsubscribe.errors.full_messages.to_sentence
      redirect_to message_train.unsubscribes_url
      false
    end

    def unsubscribe_message_from_box_user
      :unsubscribe_message.l
    end

    def unsubscribe_message_from_other
      name_column = MessageTrain.configuration.name_columns[
        @from.class.table_name.to_sym
      ]
      collective_name = @from.send(name_column)
      collective_type = @from.class.name
      :collective_unsubscribe_message.l(
        collective_name: collective_name,
        collective_type: collective_type
      )
    end
  end
end

module MessageTrain
  class BoxesController < MessageTrain::ApplicationController
    before_filter :load_conversations

    # GET /box/:division
    def show
      @conversations = @conversations.page(params[:page])
      render :show
    end

    # PATCH/PUT /box/:division
    def update
      if params[:mark_to_set].present? && @objects.present?
        @box.mark(params[:mark_to_set], @objects)
      end
      respond_to_marking
    end

    # DELETE /box/:division
    def destroy
      if ['ignore', 'unignore'].include? params[:mark_to_set]
        @box.send(params[:mark_to_set], @objects)
      end
      respond_to_marking
    end

    private

      def load_conversations
        @conversations = @box.conversations
      end
  end
end

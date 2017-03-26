module MessageTrain
  # Boxes controller
  class BoxesController < MessageTrain::ApplicationController
    before_action :load_conversations

    # GET /box/:division
    def show
      @conversations = @conversations.order(updated_at: :desc)
                                     .page(params[:page])
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
      if %w(ignore unignore).include? params[:mark_to_set]
        MessageTrain::Ignore.send(params[:mark_to_set], @objects, @box)
      end
      respond_to_marking
    end

    private

    def load_conversations
      @conversations = @box.conversations
    end
  end
end

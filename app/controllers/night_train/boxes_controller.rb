module NightTrain
  class BoxesController < NightTrain::ApplicationController
    before_filter :load_conversations

    # GET /box/in
    def show
      @conversations = @conversations.page(params[:page])
    end

    # PATCH/PUT /box/in
    def update
      if params[:mark_to_set].present? && @objects.present?
        @box.mark params[:mark_to_set], @objects
      end
      respond_to_marking
    end

    # DELETE /box/in
    def destroy
      if ['ignore', 'unignore'].include? params[:mark_to_set]
        @box.send(params[:mark_to_set], @objects)
      end
      respond_to_marking
    end

    private
      def respond_to_marking
        if @box.errors.any?
          respond_to do |format|
            format.html {
              flash[:error] = @box.message
              show
            }
            format.json { render json: { message: @box.message }, status: :unprocessable_entity }
          end
        else
          respond_to do |format|
            format.html {
              if @box.results.empty?
                flash[:alert] = @box.message
              else
                flash[:notice] = @box.message
              end
              show
            }
            format.json { render :results, status: :accepted }
          end
        end
      end

      def load_conversations
        @conversations = @box.conversations
      end

      def load_box
        @box = send(NightTrain.configuration.current_user_method).box(params[:division].to_sym)
      end
  end
end

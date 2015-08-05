module NightTrain
  class ConversationsController < NightTrain::ApplicationController
    before_filter :load_conversation

    # GET /box/in/conversations/1
    def show
      respond_to do |format|
        format.html
        format.json
      end
    end

    # PATCH/PUT /box/in/conversations/1
    def update
      if params[:mark_to_set].present? && @objects.present?
        @box.mark params[:mark_to_set], @objects
      end
      respond_to_marking
    end

    # DELETE /box/in/conversations/1
    def destroy
      if ['ignore', 'unignore'].include? params[:mark_to_set]
        @box.send(params[:mark_to_set], @conversation)
      end
      respond_to_marking
    end

    private
      def respond_to_marking
        if @box.errors.any?
          respond_to do |format|
            format.html {
              flash[:error] = @box.errors.values.to_sentence
              render :show
            }
            format.json { render json: { message: @box.message }, status: :unprocessable_entity }
          end
        else
          respond_to do |format|
            format.html {
              if @box.results.any?
                flash[:notice] = @box.message
              else
                flash[:alert] = @box.message
              end
              render :show
            }
            format.json { render :results, status: :accepted }
          end
        end
      end

      def load_conversation
        @conversation = @box.find_conversation(params[:id])
      end
  end
end

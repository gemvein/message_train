module NightTrain
  class BoxesController < NightTrain::ApplicationController
    before_filter :load_conversations
    before_filter :load_objects

    # GET /box/in
    def show
      # Everything handled by load_filters
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
              flash[:error] = @box.errors.values.to_sentence
              render :show
            }
            format.json { render json: { message: @box.errors.values.to_sentence }, status: :unprocessable_entity }
          end
        else
          if @box.results.any?
            respond_to do |format|
              format.html {
                flash[:notice] = @box.results.values.uniq.to_sentence
                render :show
              }
              format.json { render json: { message: @box.results.values.uniq.to_sentence, results: @box.results}, status: :accepted }
            end
          else
            respond_to do |format|
              format.html {
                flash[:alert] = :nothing_to_do.l
                render :show
              }
              format.json { render json: { message: :nothing_to_do.l }, status: :accepted }
            end
          end
        end
      end

      def load_objects
        @objects = {}
        @objects['conversations'] = {}
        if params[:objects].present?
          params[:objects].each do |type, list|
            list.each do |key, list_item|
              @objects[type][key.to_s] = list_item.to_i
            end
          end
        end
      end

      def load_conversations
        @conversations = @box.conversations(division: params[:division].to_sym)
      end
  end
end

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
      if @box.errors.any?
        flash[:error] = @box.errors.values.to_sentence
      elsif @box.results.any?
        flash[:notice] = @box.results.values.uniq.to_sentence
      else
        flash[:alert] = :nothing_to_do.l
      end
      render :show
    end

    # DELETE /box/in
    def destroy
      if ['ignore', 'unignore'].include? params[:mark_to_set]
        @box.send(params[:mark_to_set], @objects)
      end
      if @box.errors.any?
        flash[:error] = @box.errors.values.to_sentence
      elsif @box.results.any?
        flash[:notice] = :update_successful.l
      else
        flash[:alert] = :nothing_to_do.l
      end
      render :show
    end

    private
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

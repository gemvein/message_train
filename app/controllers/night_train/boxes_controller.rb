module NightTrain
  class BoxesController < NightTrain::ApplicationController
    before_filter :load_conversations

    # GET /box/in
    def show
      # Everything handled by load_filters
    end

    # PATCH/PUT /box/in
    def update
      params[:mark].each do |mark, ids|
        @box.mark(mark, conversations: ids)
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
      @box.ignore(params[:ignore]) if params[:ignore].present?
      @box.unignore(params[:unignore]) if params[:unignore].present?
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
      def load_conversations
        @conversations = @box.conversations(division: params[:division].to_sym)
      end
  end
end

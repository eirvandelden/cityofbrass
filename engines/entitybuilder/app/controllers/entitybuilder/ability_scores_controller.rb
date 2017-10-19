require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class AbilityScoresController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_ability_score, only: [:show, :edit, :update, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

    # GET /ability_scores
    def index
      @ability_scores = @parent_object.ability_scores

      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /ability_scores/1
    def show
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /ability_scores/new
    def new
      @ability_score = @parent_object.ability_scores.new
      @ability_score.sort_order = @parent_object.ability_scores.size

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /ability_scores/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    # POST /ability_scores
    def create
      @ability_score = @parent_object.ability_scores.new(ability_score_params)
      respond_to do |format|
        if @ability_score.save
          format.html { redirect_to ability_score_path(@parent_object, @ability_score), notice: 'ability_score was successfully added.' }
          format.json { render json: @ability_score, status: :created, location: @ability_score }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @ability_score.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /ability_scores/1
    def update
      respond_to do |format|
        if @ability_score.update(ability_score_params)
          format.html { redirect_to ability_score_path(@parent_object, @ability_score), notice: "#{@ability_score.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@ability_score.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @ability_score.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to ability_score_path(@parent_object, @ability_score), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /ability_scores/1
    def destroy
      @ability_score.destroy

      respond_to do |format|
        format.html { redirect_to ability_scores_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_ability_score
        @ability_score = @parent_object.ability_scores.find(params[:id])
        @modifier_parent_object = @ability_score
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Ability Score Tutorial')
      end

      # Only allow a trusted parameter "white list" through.
      def ability_score_params
        params.require(:ability_score).permit(
            :entity_id,
            :sort_order,
            :name,
            :description,
            :base,
            :score,
            :modifier,
            :dice
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          ability_scores_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

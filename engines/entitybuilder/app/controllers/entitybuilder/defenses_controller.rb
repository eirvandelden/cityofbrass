require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class DefensesController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_defense, only: [:show, :edit, :update, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

    # GET /defenses
    def index
      @defenses = @parent_object.defenses
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /defenses/1
    def show
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /defenses/new
    def new
      @defense = @parent_object.defenses.new
      @defense.sort_order = @parent_object.defenses.size

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /defenses/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    # POST /defenses
    def create
      @defense = @parent_object.defenses.new(defense_params)
      respond_to do |format|
        if @defense.save
          format.html { redirect_to defense_path(@parent_object, @defense), notice: 'defense was successfully added.' }
          format.json { render json: @defense, status: :created, location: @defense }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @defense.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /defenses/1
    def update
      respond_to do |format|
        if @defense.update(defense_params)
          format.html { redirect_to defense_path(@parent_object, @defense), notice: "#{@defense.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@defense.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @defense.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to defense_path(@parent_object, @defense), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /defenses/1
    def destroy
      @defense.destroy

      respond_to do |format|
        format.html { redirect_to defenses_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_defense
        @defense = @parent_object.defenses.find(params[:id])
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Defense Tutorial')
      end

      # Only allow a trusted parameter "white list" through.
      def defense_params
        params.require(:defense).permit(
            :entity_id,
            :sort_order,
            :name,
            :description,
            :bonus,
            :base,
            :ability_score,
            :misc_modifier
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          defenses_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

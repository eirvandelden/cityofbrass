# frozen_string_literal: false

require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class CasterLevelsController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_caster_level, only: [:show, :edit, :update, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

    # GET /caster_levels
    def index
      @caster_levels = @parent_object.caster_levels
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /caster_levels/1
    def show
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /caster_levels/new
    def new
      @caster_level = @parent_object.caster_levels.new
      @caster_level.sort_order = @parent_object.caster_levels.size

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /caster_levels/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    # POST /caster_levels
    def create
      @caster_level = @parent_object.caster_levels.new(caster_level_params)
      respond_to do |format|
        if @caster_level.save
          format.html { redirect_to caster_level_path(@parent_object, @caster_level), notice: 'caster_level was successfully added.' }
          format.json { render json: @caster_level, status: :created, location: @caster_level }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @caster_level.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /caster_levels/1
    def update
      respond_to do |format|
        if @caster_level.update(caster_level_params)
          format.html { redirect_to caster_level_path(@parent_object, @caster_level), notice: "#{@caster_level.caster_class} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@caster_level.caster_class} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @caster_level.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to caster_level_path(@parent_object, @caster_level), notice: "#{@parent_object.caster_class} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /caster_levels/1
    def destroy
      @caster_level.destroy

      respond_to do |format|
        format.html { redirect_to caster_levels_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_caster_level
        @caster_level = @parent_object.caster_levels.find(params[:id])
        @modifier_parent_object = @caster_level
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Caster Level Tutorial')
      end

      # Only allow a trusted parameter "white list" through.
      def caster_level_params
        params.require(:caster_level).permit(
            :entity_id,
            :sort_order,
            :caster_class,
            :level,
            :per_day,
            :bonus_per_day,
            :base_dc,
            :ability_score,
            :save_dc,
            :proficient
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          caster_levels_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

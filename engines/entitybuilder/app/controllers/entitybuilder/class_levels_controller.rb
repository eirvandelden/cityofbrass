require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class ClassLevelsController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_class_level, only: [:show, :edit, :update, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

    # GET /class_levels
    def index
      @class_levels = @parent_object.class_levels
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /class_levels/1
    def show
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /class_levels/new
    def new
      @class_level = @parent_object.class_levels.new
      @class_level.sort_order = @parent_object.class_levels.size

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /class_levels/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    # POST /class_levels
    def create
      @class_level = @parent_object.class_levels.new(class_level_params)
      respond_to do |format|
        if @class_level.save
          format.html { redirect_to class_level_path(@parent_object, @class_level), notice: 'class_level was successfully added.' }
          format.json { render json: @class_level, status: :created, location: @class_level }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @class_level.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /class_levels/1
    def update
      respond_to do |format|
        if @class_level.update(class_level_params)
          format.html { redirect_to class_level_path(@parent_object, @class_level), notice: "#{@class_level.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@class_level.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @class_level.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to class_level_path(@parent_object, @class_level), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /class_levels/1
    def destroy
      @class_level.destroy

      respond_to do |format|
        format.html { redirect_to class_levels_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_class_level
        @class_level = @parent_object.class_levels.find(params[:id])
        @modifier_parent_object = @class_level
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Class Level Tutorial')
      end

      # Only allow a trusted parameter "white list" through.
      def class_level_params
        params.require(:class_level).permit(
            :entity_id,
            :sort_order,
            :name,
            :description,
            :level,
            :hit_dice,
            :hit_points
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          class_levels_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

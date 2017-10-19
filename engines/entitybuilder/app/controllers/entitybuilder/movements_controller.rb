require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class MovementsController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_movement, only: [:show, :edit, :update, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

    # GET /movements
    def index
      @movements = @parent_object.movements

      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /movements/1
    def show
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /movements/new
    def new
      @movement = @parent_object.movements.new
      @movement.sort_order = @parent_object.movements.size

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /movements/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    # POST /movements
    def create
      @movement = @parent_object.movements.new(movement_params)

      respond_to do |format|
        if @movement.save
          format.html { redirect_to movement_path(@parent_object, @movement), notice: 'movement was successfully added.' }
          format.json { render json: @movement, status: :created, location: @movement }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @movement.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /movements/1
    def update
      respond_to do |format|
        if @movement.update(movement_params)
          format.html { redirect_to movement_path(@parent_object, @movement), notice: "#{@movement.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@movement.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @movement.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to movement_path(@parent_object, @movement), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /movements/1
    def destroy
      @movement.destroy

      respond_to do |format|
        format.html { redirect_to movements_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_movement
        @movement = @parent_object.movements.find(params[:id])
        @modifier_parent_object = @movement
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Movement Tutorial')
      end

      # Only allow a trusted parameter "white list" through.
      def movement_params
        params.require(:movement).permit(
            :entity_id,
            :sort_order,
            :name,
            :description,
            :bonus,
            :base,
            :dice,
            :ability_score,
            :misc_modifier
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          movements_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

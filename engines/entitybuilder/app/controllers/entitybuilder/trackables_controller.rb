require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class TrackablesController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_trackable, only: [:show, :edit, :edit_sheet, :update, :update_sheet, :update_card, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

    # GET /trackables
    def index
      @trackables = @parent_object.trackables

      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /trackables/1
    def show
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /trackables/new
    def new
      @trackable = @parent_object.trackables.new
      @trackable.sort_order = @parent_object.trackables.size

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /trackables/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    def edit_sheet
      respond_to do |format|
          format.html
          format.js
      end
    end

    # POST /trackables
    def create
      @trackable = @parent_object.trackables.new(trackable_params)

      respond_to do |format|
        if @trackable.save
          format.html { redirect_to trackable_path(@parent_object, @trackable), notice: 'trackable was successfully added.' }
          format.json { render json: @trackable, status: :created, location: @trackable }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @trackable.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /trackables/1
    def update
      respond_to do |format|
        if @trackable.update(trackable_params)
          format.html { redirect_to trackable_path(@parent_object, @trackable), notice: "#{@trackable.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@trackable.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @trackable.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_sheet
      @clickable = @parent_object.can_edit?(current_user, admin_signed_in?, @parent_type)

      respond_to do |format|
        if @trackable.update(trackable_params)
          @hit_points = @parent_object.trackables.first unless @parent_object.trackables.nil?
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@trackable.name} has been updated." }
        else
          format.json { render json: @trackable.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_card
      @clickable = @parent_object.can_edit?(current_user, admin_signed_in?, @parent_type)

      respond_to do |format|
        if @trackable.update(trackable_params)
          @hit_points = @parent_object.trackables.first unless @parent_object.trackables.nil?
          format.js   { flash.now[:notice] = "#{@trackable.name} has been updated." }
        else
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to trackable_path(@parent_object, @trackable), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /trackables/1
    def destroy
      @trackable.destroy

      respond_to do |format|
        format.html { redirect_to trackables_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_trackable
        @trackable = @parent_object.trackables.find(params[:id])
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Trackable Tutorial')
      end

      # Only allow a trusted parameter "white list" through.
      def trackable_params
        params.require(:trackable).permit(
            :entity_id,
            :sort_order,
            :name,
            :description,
            :minimum,
            :maximum,
            :current,
            :temporary
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          trackables_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

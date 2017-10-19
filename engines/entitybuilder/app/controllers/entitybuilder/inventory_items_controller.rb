require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class InventoryItemsController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization, except: [:show]
    before_action :set_inventory_item, only: [:show, :edit, :update, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

    # GET /inventory_items
    def index
      @items = @parent_object.items

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /inventory_items/1
    def show
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /inventory_items/new
    def new
      @inventory_item = @parent_object.inventory_items.new
      @inventory_item.sort_order = @parent_object.inventory_items.size

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /inventory_items/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    # POST /inventory_items
    def create
      @inventory_item = @parent_object.inventory_items.new(inventory_item_params)

      respond_to do |format|
        if @inventory_item.save
          format.html { redirect_to inventory_item_path(@parent_object, @inventory_item), notice: 'inventory_item was successfully added.' }
          format.json { render json: @inventory_item, status: :created, location: @inventory_item }
          format.js
        else
          format.html { render action: "new"  }
          format.json { render json: @inventory_item.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /inventory_items/1
    def update
      respond_to do |format|
        if @inventory_item.update(inventory_item_params)
          format.html { redirect_to inventory_item_path(@parent_object, @inventory_item), notice: "#{@inventory_item.item.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@inventory_item.item.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @inventory_item.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to inventory_item_path(@parent_object, @inventory_item), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /inventory_items/1
    def destroy
      @inventory_item.destroy

      respond_to do |format|
        format.html { redirect_to inventory_items_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_inventory_item
        @inventory_item = @parent_object.inventory_items.find(params[:id])
        @modifier_parent_object = @inventory_item
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Inventory Item Tutorial')
      end

      # Only allow a trusted parameter "white list" through.
      def inventory_item_params
        params.require(:inventory_item).permit(
            :entity_id,
            :sort_order,
            :item_id,
            :quantity,
            :equipped,
            :carried,
            :detail
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          inventory_items_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

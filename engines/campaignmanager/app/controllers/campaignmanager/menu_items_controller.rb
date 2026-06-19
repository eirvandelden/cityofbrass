require_dependency "campaignmanager/application_controller"

module Campaignmanager
  class MenuItemsController < ApplicationController
    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_menu_item, only: [ :show, :edit, :update, :destroy ]

    # GET /menu_items
    def index
      @menu_items = @parent_object.menu_items
    end

    # GET /menu_items/1
    def show
    end

    # GET /menu_items/new
    def new
      sort_order = 0
      sort_order = @parent_object.menu_items.order_sort_order.last.sort_order.to_i + 1 unless @parent_object.menu_items.order_sort_order.last.nil?

      @menu_item = @parent_object.menu_items.new
      @menu_item.sort_order = sort_order
    end

    # GET /menu_items/1/edit
    def edit
    end

    # POST /menu_items
    def create
      @menu_item = @parent_object.menu_items.new(menu_item_params)

      respond_to do |format|
        if @menu_item.save
          format.html { redirect_to campaign_menu_items_path(@parent_object), notice: 'Menu item was successfully added.' }
          format.js
        else
          format.html { render action: "new" }
          format.js
        end
      end
    end

    # PATCH/PUT /menu_items/1
    def update
      respond_to do |format|
        if @menu_item.update(menu_item_params)
          format.html { redirect_to campaign_menu_items_path(@parent_object), notice: "#{@menu_item.item_label} was successfully updated." }
          format.js { flash.now[:notice] = "#{@menu_item.item_label} has been updated." }
        else
          format.html { render action: "edit" }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to campaign_menu_items_path(@parent_object) }
          format.js { flash.now[:notice] = "#{@parent_object.name} was successfully updated." }
        else
          format.html { render action: "index" }
          format.js
        end
      end
    end

    # DELETE /menu_items/1
    def destroy
      @menu_item.destroy

      respond_to do |format|
        format.html { redirect_to campaign_menu_items_path(@parent_object) }
        format.js
      end
    end

    private

      def set_menu_item
        @menu_item = @parent_object.menu_items.find(params[:id])
      end

      def menu_item_params
        params.require(:menu_item).permit(
          :menu_itemable_id,
          :menu_itemable_type,
          :sort_order,
          :item_label,
          :item_link
        )
      end

      def entity_params
        params.require(:campaign).permit(
          menu_items_attributes: [
            :id,
            :sort_order,
            :_destroy
          ]
        )
      end
  end
end

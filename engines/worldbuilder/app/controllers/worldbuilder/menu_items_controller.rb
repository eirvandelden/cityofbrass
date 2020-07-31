# frozen_string_literal: false

require_dependency "worldbuilder/application_controller"

module Worldbuilder
  class MenuItemsController < ApplicationController

    before_action :authenticate_user!
    before_action :set_type
    before_action :set_resident
    before_action :set_parent_object
    before_action :check_authorization
    before_action :set_menu_item, only: [:show, :edit, :update, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

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
      sort_order = @parent_object.menu_items.order_sort_order.last.sort_order.to_i+1 unless @parent_object.menu_items.order_sort_order.last.nil?

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
          format.html { redirect_to menu_item_path(@parent_object, @menu_item), notice: 'menu_item was successfully added.' }
          format.json { render json: @menu_item, status: :created, location: @menu_item }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @menu_item.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /menu_items/1
    def update
      respond_to do |format|
        if @menu_item.update(menu_item_params)
          format.html { redirect_to menu_item_path(@parent_object, @menu_item), notice: "#{@menu_item.item_label} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@menu_item.item_label} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @menu_item.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to menu_item_path(@parent_object, @menu_item), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /menu_items/1
    def destroy
      @menu_item.destroy

      respond_to do |format|
        format.html { redirect_to menu_items_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_type
        @type = type
      end

      def type
        params.each do |key, value|
         if key.include?"_id"
           unless key == "resident_id"
             return key.gsub('_id', '')
           end
         end
        end
      end

      def set_resident
        @resident = District.find_by_id(params[:district_id]).resident unless params[:district_id].nil?
        if @resident.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_parent_object
        @parent_object = @resident.send("#{@type.tableize}").find_by_id(params["#{@type}_id"])
        if @parent_object.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_menu_item
        @menu_item = @parent_object.menu_items.find(params[:id])
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('WB Menu Tutorial')
      end

      def check_authorization
        if @parent_object
          unless @parent_object.can_edit?(current_user, admin_signed_in?)
            render template: 'errors/403', layout: 'layouts/application', status: 403
          end
        else
          unless @resident.can_edit?(current_user, admin_signed_in?)
            render template: 'errors/403', layout: 'layouts/application', status: 403
          end
        end
      end

      # Only allow a trusted parameter "white list" through.
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
        params.require(@type).permit(
          menu_items_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

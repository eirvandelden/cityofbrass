require_dependency "rulebuilder/application_controller"

module Rulebuilder
  module Admin
    class StockItemsController < ItemsController
      before_action :set_type
      before_action :set_route_namespace
      before_action :check_authorization, only: [ :index, :new, :create, :edit, :update, :destroy, :options ]
      before_action :set_item,            only: [ :show, :edit, :update, :destroy, :options ]
      before_action :set_items,           only: [ :index ]

      def create
        @item = klass.new(item_params)
        @item.build_gallery_image_join if @item.gallery_image_join.nil?

        respond_to do |format|
          if @item.save
            format.html { redirect_to edit_admin_stock_item_path(@item), notice: @item.name + ' was successfully created.' }
            format.json { render json: @item, status: :created, location: @item }
            format.js
          else
            format.html { render action: "new" }
            format.json { render json: @item.errors, status: :unprocessable_entity }
            format.js
          end
        end
      end

      def update
        respond_to do |format|
          if @item.update(item_params)
            format.html { redirect_to edit_admin_stock_item_path(@item) }
            format.json { head :no_content }
            format.js   { flash.now[:notice] = "#{@item.name} has been updated." }
          else
            format.html { render action: 'edit' }
            format.json { render json: @item.errors, status: :unprocessable_entity }
            format.js
          end
        end
      end

      def destroy
        respond_to do |format|
          if @item.update(item_params)
            @item.destroy
            format.html { redirect_to admin_stock_items_path }
          else
            format.html { render action: 'options' }
          end
        end
      end

      private
        def set_route_namespace
          @route_namespace = :admin
        end

        def set_type
          @type = 'StockItem'
        end

        def set_items
          @items = StockItem.short.order_name.search(params[:search]).core_rules_filter(params[:core_rules_filter]).page(params[:page]).per(100)
        end

        def set_item
          params_id = params["#{@type.underscore}_id"] ||= params[:id]
          @item = klass.find_by_id(params_id)

          if @item.nil?
            render template: 'errors/404', layout: 'layouts/application', status: 404
          end
        end

        def check_authorization
          unless admin_signed_in?
            render template: 'errors/403', layout: 'layouts/application', status: 403
          end
        end
    end
  end
end

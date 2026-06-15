require_dependency "rulebuilder/application_controller"

module Rulebuilder
  class StockItemsController < ItemsController

    skip_before_action :authenticate_user!, only: [:show]
    skip_before_action :check_user_status,  only: [:show]

    before_action :set_type
    before_action :check_authorization, only: [:new, :create, :edit, :update, :destroy, :options]
    before_action :set_item,            only: [:show, :edit, :update, :destroy, :options]
    before_action :set_items,           only: [:index]
    before_action :can_show,            only: [:show]

    private
      def set_type
        @type = 'StockItem'
      end

      def set_items
        @items = visible_items.short.order_name.search(params[:search]).core_rules_filter(params[:core_rules_filter]).page(params[:page]).per(100)
      end

      def visible_items
        return StockItem.all if admin_signed_in?

        StockItem.where(privacy: [ "Public", "Residents" ])
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

      def can_show
        unless @item.can_show?(current_user, admin_signed_in?, @type)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

  end
end

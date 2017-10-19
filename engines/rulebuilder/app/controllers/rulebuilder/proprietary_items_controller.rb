require_dependency "rulebuilder/application_controller"

module Rulebuilder
  class ProprietaryItemsController < ItemsController

    before_action :set_type
    before_action :check_authorization, only: [:index, :new, :create, :edit, :update, :destroy, :options]
    before_action :set_item,            only: [:show, :edit, :update, :destroy, :options]
    before_action :set_items,           only: [:index]

    private
      def set_type
        @type = 'ProprietaryItem'
      end

      def set_items
        @items = ProprietaryItem.short.order_name.search(params[:search]).core_rules_filter(params[:core_rules_filter]).page(params[:page]).per(100)
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

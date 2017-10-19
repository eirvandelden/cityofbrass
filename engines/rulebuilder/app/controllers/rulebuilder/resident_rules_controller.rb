require_dependency "rulebuilder/application_controller"

module Rulebuilder
  class ResidentRulesController < RulesController

    before_action :set_type
    before_action :set_rule,   only: [:show, :edit, :update, :destroy, :options]
    before_action :set_rules,  only: [:index]
    before_action :can_show,   only: [:show]
    before_action :can_edit, except: [:index, :show, :new, :create]

    before_action :check_quota, only: [:new, :create]

    private
      def set_type
        @type = 'ResidentRule'
      end

      def set_rules
        @rules = current_user.resident.send("#{@type.tableize}").short.order_name.shared.search(params[:search]).core_rules_filter(params[:core_rules]).rule_type_filter(params[:rule_type]).page(params[:page]).per(100)

        if @rules.blank?
          @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('RB Rule Index')
        end
      end

      def set_rule
        params_id = params["#{@type.underscore}_id"] ||= params[:id]
        @rule = klass.joins(:user).find_by_id(params_id)

        if @rule.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def can_show
        unless @rule.can_show?(current_user, admin_signed_in?, @type)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      def can_edit
        unless @rule.can_edit?(current_user, admin_signed_in?, @type)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

  end
end

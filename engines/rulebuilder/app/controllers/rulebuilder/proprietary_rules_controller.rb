# frozen_string_literal: false

require_dependency "rulebuilder/application_controller"

module Rulebuilder
  class ProprietaryRulesController < RulesController

    before_action :set_type
    before_action :check_authorization, only: [:index, :new, :create, :edit, :update, :destroy, :options]
    before_action :set_rule,            only: [:show, :edit, :update, :destroy, :options]
    before_action :set_rules,           only: [:index]

    private
      def set_type
        @type = 'ProprietaryRule'
      end

      def set_rules
        @rules = ProprietaryRule.short.order_name.shared.search(params[:search]).core_rules_filter(params[:core_rules]).rule_type_filter(params[:rule_type]).page(params[:page]).per(100)
      end

      def set_rule
        params_id = params["#{@type.underscore}_id"] ||= params[:id]
        @rule = klass.find_by_id(params_id)

        if @rule.nil?
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

require_dependency "rulebuilder/application_controller"

module Rulebuilder
  class ProprietarySpellsController < SpellsController

    before_action :set_type
    before_action :check_authorization, only: [:index, :new, :create, :edit, :update, :destroy, :options]
    before_action :set_spell,           only: [:show, :edit, :update, :destroy, :options]
    before_action :set_spells,          only: [:index]

    private
      def set_type
        @type = 'ProprietarySpell'
      end

      def set_spells
        @spells = ProprietarySpell.short.order_name.search(params[:search]).core_rules_filter(params[:core_rules_filter]).page(params[:page]).per(100)
      end

      def set_spell
        params_id = params["#{@type.underscore}_id"] ||= params[:id]
        @spell = klass.find_by_id(params_id)

        if @spell.nil?
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

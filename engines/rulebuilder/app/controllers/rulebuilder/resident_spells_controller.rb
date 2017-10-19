require_dependency "rulebuilder/application_controller"

module Rulebuilder
  class ResidentSpellsController < SpellsController

    before_action :set_type
    before_action :set_spell,  only: [:show, :edit, :update, :destroy, :options]
    before_action :set_spells, only: [:index]
    before_action :can_show,   only: [:show]
    before_action :can_edit, except: [:index, :show, :new, :create]

    before_action :check_quota, only: [:new, :create]

    private
      def set_type
        @type = 'ResidentSpell'
      end

      def set_spells
        @spells = current_user.resident.send("#{@type.tableize}").short.order_name.search(params[:search]).core_rules_filter(params[:core_rules_filter]).page(params[:page]).per(100)

        if @spells.blank?
          @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('RB Spell Index')
        end
      end

      def set_spell
        params_id = params["#{@type.underscore}_id"] ||= params[:id]
        @spell = klass.joins(:user).find_by_id(params_id)

        if @spell.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def can_show
        unless @spell.can_show?(current_user, admin_signed_in?, @type)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      def can_edit
        unless @spell.can_edit?(current_user, admin_signed_in?, @type)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

  end
end

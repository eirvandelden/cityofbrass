require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class ResidentCreaturesController < EntitiesController

    before_action :set_type
    before_action :set_entity,          only: [:edit, :update, :update_notes, :notes, :destroy, :options]
    before_action :set_entity_for_show, only: [:show, :card_summary]

    before_action :set_entity_for_play, only: [:profile, :sheet, :card]
    before_action :set_profile,         only: [:profile]
    before_action :set_sheet,           only: [:sheet, :card]

    before_action :set_entities,        only: [:index]

    before_action :can_show,            only: [:show, :card_summary]
    before_action :can_sheet,           only: [:sheet, :profile, :card]
    before_action :can_edit,          except: [:index, :show, :profile, :sheet, :card, :card_summary, :new, :create]

    before_action :check_quota,         only: [:new, :create]

    private
      def set_type
        @type = 'ResidentCreature'
      end

      def set_entities
        @entities = current_user.resident.send("#{@type.tableize}").includes([:gallery_image]).search(params[:search]).core_rules_filter(params[:core_rules_filter]).short.page(params[:page])

        if current_user.is_free?
          @sub = "#{current_user.resident.send("#{@type.tableize}").count} / #{Quota.limit(current_user, @type)}"
        end

        if @entities.blank?
          @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Creature Index')
        end
      end

      def set_entity
        params_id = params["#{@type.underscore}_id"] ||= params[:id]
        @entity = klass.joins(:user).find_by_id(params_id)
        if @entity.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
        @parent_object = @entity
      end

      def set_entity_for_show
        @entity = klass.joins(:user).includes([:class_levels, :descriptors]).find_by_id(params_id)
        if @entity.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
        @parent_object = @entity
      end

      def set_entity_for_play
        @entity = klass.joins(:user).includes([:ability_scores, :attacks, :class_levels, :caster_levels, :defenses, :descriptors, :saving_throws, :descriptors, :base_values, :rules, :modifiers, :movements, :skills, :trackables, :items, :currencies, :prepared_spells]).find_by_id(params_id)
        if @entity.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
        @parent_object = @entity
      end

  end
end

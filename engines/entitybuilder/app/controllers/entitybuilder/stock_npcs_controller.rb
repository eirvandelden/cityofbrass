# frozen_string_literal: false

require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class StockNpcsController < EntitiesController

    before_action :set_type
    before_action :check_authorization,  only: [:new, :create, :edit, :update, :update_notes, :destroy, :options]
    before_action :set_entity,           only: [:edit, :update, :update_notes, :destroy, :options]
    before_action :set_entity_for_show,  only: [:show, :card_summary]

    before_action :set_entity_for_play,  only: [:profile, :sheet, :card]
    before_action :set_profile,          only: [:profile]
    before_action :set_sheet,            only: [:sheet, :card]

    before_action :set_entities,         only: [:index]

    before_action :can_show,             only: [:show, :card_summary]
    before_action :can_sheet,            only: [:sheet, :profile, :card, :card_summary]

    private
      def set_type
        @type = 'StockNpc'
      end

      def set_entities
        if admin_signed_in?
          @entities = klass.includes([:class_levels, :gallery_image]).search(params[:search]).core_rules_filter(params[:core_rules_filter]).short.order_name.page(params[:page])
        else
          @entities = klass.includes([:class_levels, :gallery_image]).where(privacy: "Residents").search(params[:search]).core_rules_filter(params[:core_rules_filter]).short.order_name.page(params[:page])
        end
      end

      def set_entity
        params_id = params["#{@type.underscore}_id"] ||= params[:id]
        @entity = klass.find_by_id(params_id)
        if @entity.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
        @parent_object = @entity
      end

      def set_entity_for_show
        @entity = klass.includes([:class_levels, :descriptors]).find_by_id(params_id)
        if @entity.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
        @parent_object = @entity
      end

      def set_entity_for_play
        @entity = klass.includes([:ability_scores, :attacks, :class_levels, :caster_levels, :defenses, :descriptors, :saving_throws, :descriptors, :base_values, :rules, :modifiers, :movements, :skills, :trackables, :items, :currencies, :prepared_spells]).find_by_id(params_id)
        if @entity.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
        @parent_object = @entity
      end

  end
end

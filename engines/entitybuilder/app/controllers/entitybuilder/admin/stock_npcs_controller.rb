require_dependency "entitybuilder/application_controller"

module Entitybuilder
  module Admin
    class StockNpcsController < EntitiesController
      before_action :set_type
      before_action :check_authorization,  only: [ :index, :new, :create, :edit, :update, :update_notes, :destroy, :options ]
      before_action :set_entity,           only: [ :edit, :update, :update_notes, :destroy, :options ]
      before_action :set_entity_for_show,  only: [ :show, :card_summary ]

      before_action :set_entity_for_play,  only: [ :profile, :sheet, :card ]
      before_action :set_profile,          only: [ :profile ]
      before_action :set_sheet,            only: [ :sheet, :card ]

      before_action :set_entities,         only: [ :index ]

      before_action :can_show,             only: [ :show, :card_summary ]
      before_action :can_sheet,            only: [ :sheet, :profile, :card, :card_summary ]

      def new
        super
        @entity.privacy = "Private"
      end

      def create
        @entity = klass.new(entity_params)
        @entity.build_gallery_image_join if @entity.gallery_image_join.nil?
        @entity.build_campaign_join if @entity.campaign_join.nil?

        respond_to do |format|
          if @entity.save
            CoreRules::Entity.add_defaults(@entity)
            format.html { redirect_to edit_admin_stock_npc_path(@entity), notice: @entity.name + ' was successfully created.' }
            format.json { render action: 'show', status: :created, location: @entity }
          else
            format.html { render action: 'new' }
            format.json { render json: @entity.errors, status: :unprocessable_entity }
          end
        end
      end

      def update
        respond_to do |format|
          if @entity.update(entity_params)
            format.html { redirect_to edit_admin_stock_npc_path(@entity) }
            format.json { head :no_content }
            format.js   { flash.now[:notice] = "#{@entity.name} has been updated." }
          else
            format.html { render action: 'edit' }
            format.json { render json: @entity.errors, status: :unprocessable_entity }
            format.js
          end
        end
      end

      def destroy
        respond_to do |format|
          if @entity.update(entity_params)
            @entity.destroy
            format.html { redirect_to admin_stock_npcs_path }
          else
            format.html { render action: 'options' }
          end
        end
      end

      private
        def set_type
          @type = 'StockNpc'
        end

        def set_entities
          @entities = klass.includes([ :class_levels, :gallery_image ]).search(params[:search]).core_rules_filter(params[:core_rules_filter]).short.order_name.page(params[:page])
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
          @entity = klass.includes([ :class_levels, :descriptors ]).find_by_id(params_id)
          if @entity.nil?
            render template: 'errors/404', layout: 'layouts/application', status: 404
          end
          @parent_object = @entity
        end

        def set_entity_for_play
          @entity = klass.includes([ :ability_scores, :attacks, :class_levels, :caster_levels, :defenses, :descriptors, :saving_throws, :descriptors, :base_values, :rules, :modifiers, :movements, :skills, :trackables, :items, :currencies, :prepared_spells ]).find_by_id(params_id)
          if @entity.nil?
            render template: 'errors/404', layout: 'layouts/application', status: 404
          end
          @parent_object = @entity
        end
    end
  end
end

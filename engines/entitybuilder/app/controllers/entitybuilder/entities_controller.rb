require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class EntitiesController < ApplicationController

    # GET /entities
    # GET /entities.json
    def index
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /entities/1
    # GET /entities/1.json
    def sheet
      respond_to do |format|
        format.html
        format.html.phone
        format.json
        format.js
      end
    end

    # GET /entities/1
    # GET /entities/1.json
    def profile
      respond_to do |format|
        format.html
        format.html.phone
        format.json
        format.js
      end
    end

    # GET /entities/1
    # GET /entities/1.json
    def card
      respond_to do |format|
        format.html
        format.html.phone
        format.js
      end
    end

    # GET /entities/1
    # GET /entities/1.json
    def card_summary
      respond_to do |format|
        format.js
      end
    end

    # GET /entities/1
    # GET /entities/1.json
    def notes
      respond_to do |format|
        format.js
      end
    end

    # GET /entities/1
    # GET /entities/1.json
    def show
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /entities/new
    def new
      @entity = klass.new
      @entity.resident_id = current_user.resident.id if @type.include?"Resident"
      @entity.build_gallery_image_join if @entity.gallery_image_join.nil?
      @entity.build_campaign_join if @entity.campaign_join.nil?
    end

    # GET /entities/1/:edit
    def edit
      @entity.build_gallery_image_join if @entity.gallery_image_join.nil?
      @entity.build_campaign_join if @entity.campaign_join.nil?
    end

    # GET /entities/1/:options
    def options
    end

    # POST /entities
    # POST /entities.json
    def create
      @entity = klass.new(entity_params)
      @entity.resident_id = current_user.resident.id if @type.include?"Resident"
      @entity.build_gallery_image_join if @entity.gallery_image_join.nil?
      @entity.build_campaign_join if @entity.campaign_join.nil?

      respond_to do |format|
        if @entity.save

          CoreRules::Entity.add_defaults(@entity)
          #if @type.include?"Creature"
            #eb_creature_add_rule_set(@entity)
          #else
            #eb_character_add_rule_set(@entity)
          #end

          format.html { redirect_to edit_polymorphic_path(@entity), notice: @entity.name + ' was successfully created.' }
          format.json { render action: 'show', status: :created, location: @entity }
        else
          format.html { render action: 'new' }
          format.json { render json: @entity.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /entities/1
    # PATCH/PUT /entities/1.json
    def update
      respond_to do |format|
        if @entity.update(entity_params)
          format.html { redirect_to edit_polymorphic_path(@entity) }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@entity.name} has been updated." }
        else
          format.html { render action: 'edit' }
          format.json { render json: @entity.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /entities/1
    # PATCH/PUT /entities/1.json
    def update_notes
      respond_to do |format|
        if @entity.update(entity_params)
          format.js   { flash.now[:notice] = "#{@entity.name} notes has been saved." }
        else
          format.js
        end
      end
    end

    # DELETE /entities/1
    # DELETE /entities/1.json
    def destroy
      respond_to do |format|
        if @entity.update(entity_params)
          @entity.destroy
          format.html { redirect_to polymorphic_path(@type.tableize) }
        else
          format.html { render action: 'options' }
        end
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.

      def klass
        klass = "Entitybuilder::#{@type}".constantize
      end

      def params_id
        params_id = params["#{@type.underscore}_id"] ||= params[:id]
      end

      def set_profile
        @prepared_spells = @entity.prepared_known_spells.to_a

        @descriptors_core = @entity.descriptors.reject { |d| ("Alignment, Size, Race, Species, Type, Classification").include?(d.name) } unless @entity.descriptors.nil?

        @xp = @entity.descriptors.detect { |d| d.name == "Experience" } unless @entity.descriptors.nil?
        @cr = @entity.descriptors.detect { |d| ("Challenge, Challenge Rating, Level").include?(d.name) } unless @entity.descriptors.nil?

        @armor_class = @entity.defenses.first unless @entity.defenses.nil?
        @defenses_w_bonus = @entity.defenses.reject { |d| @armor_class.name.include?(d.name) || !d.description.blank? } unless @entity.defenses.nil?
        @defenses_w_text = @entity.defenses.reject { |d| @armor_class.name.include?(d.name) || d.description.blank? } unless @entity.defenses.nil?


        @hit_points = @entity.trackables.first unless @entity.trackables.nil?
        @trackables = @entity.trackables.reject { |d| @hit_points.name.include?(d.name) } unless @entity.trackables.nil?

        @attacks_melee   = @entity.attacks.select { |d| ("Melee").include?(d.attack_type) } unless @entity.attacks.nil?
        @attacks_range   = @entity.attacks.select { |d| ("Range").include?(d.attack_type) } unless @entity.attacks.nil?
        @attacks_special = @entity.attacks.select { |d| ("Special").include?(d.attack_type) } unless @entity.attacks.nil?

        @initiative = @entity.movements.detect { |d| d.name == "Initiative" }
        @movements = @entity.movements.reject { |d| d.name == "Initiative" } unless @entity.movements.nil?

        @clickable = @entity.clickable?(current_user, admin_signed_in?, @type)
      end

      def set_sheet
        @prepared_spells = @entity.prepared_known_spells.to_a

        @armor_class = @entity.defenses.first unless @entity.defenses.nil?
        @defenses_w_bonus = @entity.defenses.reject { |d| @armor_class.name.include?(d.name) || !d.description.blank? } unless @entity.defenses.nil?
        @defenses_w_text = @entity.defenses.reject { |d| @armor_class.name.include?(d.name) || d.description.blank? } unless @entity.defenses.nil?

        @hit_points = @entity.trackables.first unless @entity.trackables.nil?

        @initiative = @entity.movements.detect { |d| d.name == "Initiative" }
        if @initiative.nil?
          @movements = @entity.movements unless @entity.movements.nil?
        else
          @movements = @entity.movements.reject { |d| @initiative.name.include?(d.name) } unless @entity.movements.nil?
        end
        @speed = @movements.first unless @movements.nil?
        @movements = @movements.reject { |d| @speed.name.include?(d.name) } unless @movements.nil?

        @clickable = @entity.clickable?(current_user, admin_signed_in?, @type)
      end

      def can_show
        unless @entity.can_show?(current_user, admin_signed_in?, @type)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      def can_sheet
        unless @entity.can_sheet?(current_user, admin_signed_in?, @type)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      def can_edit
        unless @entity.can_edit?(current_user, admin_signed_in?, @type)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      def check_authorization
        unless admin_signed_in?
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      # Only allow a trusted parameter "white list" through.
      def entity_params
        params.require(@type.underscore.to_sym).permit(
          :resident_id,
          :name,
          :publisher,
          :source,
          :is_3pp,
          :privacy,
          :sheet_privacy,
          :core_rules,
          :short_description,
          :full_description,
          :notes,
          :introduction,
          :tag_list,
          gallery_image_join_attributes: [:id, :image_id, :_destroy],
          campaign_join_attributes: [:id, :campaign_id, :_destroy]
        )
      end
  end
end

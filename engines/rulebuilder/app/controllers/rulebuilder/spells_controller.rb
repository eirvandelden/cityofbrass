# frozen_string_literal: false

require_dependency "rulebuilder/application_controller"

module Rulebuilder
  class SpellsController < ApplicationController

    # GET /spells
    def index
      if (current_user.is_free?) && (@type.include?"Resident")
        @sub = "#{current_user.resident.resident_spells.count} / #{Quota.limit(current_user, @type)}"
      end
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /spells/1
    def show
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /spells/new
    def new
      @spell = klass.new
      @spell.resident_id = current_user.resident.id
      @spell.build_gallery_image_join if @spell.gallery_image_join.nil?

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /spells/1/edit
    def edit
      @spell.build_gallery_image_join if @spell.gallery_image_join.nil?

      respond_to do |format|
        format.html
        format.js
      end
    end

    # POST /spells
    def create
      @spell = klass.new (spell_params)
      @spell.resident_id = current_user.resident.id
      @spell.build_gallery_image_join if @spell.gallery_image_join.nil?

      respond_to do |format|
        if @spell.save
          format.html { redirect_to edit_polymorphic_path(@spell), notice: @spell.name + ' was successfully created.' }
          format.json { render json: @spell, status: :created, location: @spell }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @spell.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /spells/1
    def update
      respond_to do |format|
        if @spell.update(spell_params)
          format.html { redirect_to edit_polymorphic_path(@spell) }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@spell.name} has been updated." }
        else
          format.html { render action: 'edit' }
          format.json { render json: @spell.errors, status: :unprocessable_spell }
          format.js
        end
      end
    end

    # GET /spells/1/:options
    def options
    end

    # DELETE /spells/1
    def destroy
      respond_to do |format|
        if @spell.update(spell_params)
          @spell.destroy
          format.html { redirect_to polymorphic_path(@type.tableize) }
        else
          format.html { render action: 'options' }
        end
      end
    end

    private

      def klass
        klass = "Rulebuilder::#{@type}".constantize
      end

      # Only allow a trusted parameter "white list" through.
      def spell_params
        params.require(@type.underscore.to_sym).permit(
          :parent_id,
          :resident_id,
          :name,
          :publisher,
          :source,
          :is_3pp,
          :short_description,
          :full_description,
          :core_rules,
          :level_list,
          :school,
          :casting_time,
          :target,
          :range,
          :area,
          :components,
          :effect,
          :duration,
          :saving_throw,
          :spell_resistance,
          :tag_list,
          gallery_image_join_attributes: [:id, :image_id, :_destroy]
        )
      end

  end
end

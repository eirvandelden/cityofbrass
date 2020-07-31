# frozen_string_literal: false

require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class KnownSpellsController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization, except: [:show]
    before_action :set_known_spell, only: [:show, :edit, :use_spell, :update, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

    # GET /known_spells
    def index
      @spells = @parent_object.spells

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /known_spells/1
    def show
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /known_spells/new
    def new
      @known_spell = @parent_object.known_spells.new
      @known_spell.sort_order = @parent_object.known_spells.size

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /known_spells/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    # GET /known_spells/1/use_spell
    def use_spell
      @type = @parent_type
      set_used = @known_spell.used == true ? false : true

      @known_spell.update_attributes({:used => set_used})
      @prepared_spells = @parent_object.prepared_known_spells.includes(:spell).to_a

      respond_to do |format|
        format.html
        format.js
      end
    end

    # POST /known_spells
    def create
      @known_spell = @parent_object.known_spells.new(known_spell_params)

      respond_to do |format|
        if @known_spell.save
          format.html { redirect_to known_spell_path(@parent_object, @known_spell), notice: 'known_spell was successfully added.' }
          format.json { render json: @known_spell, status: :created, location: @known_spell }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @known_spell.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /known_spells/1
    def update
      respond_to do |format|
        if @known_spell.update(known_spell_params)
          format.html { redirect_to known_spell_path(@parent_object, @known_spell), notice: "#{@known_spell.spell.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@known_spell.spell.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @known_spell.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to known_spell_path(@parent_object, @known_spell), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /known_spells/1
    def destroy
      @known_spell.destroy

      respond_to do |format|
        format.html { redirect_to known_spells_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def params_id
        params_id = params["known_spell_id"] ||= params[:id]
      end

      def set_known_spell
        @known_spell = @parent_object.known_spells.find(params[:id])
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Known Spell Tutorial')
      end

      # Only allow a trusted parameter "white list" through.
      def known_spell_params
        params.require(:known_spell).permit(
            :entity_id,
            :sort_order,
            :spell_id,
            :prepared,
            :spell_class,
            :level,
            :at_will,
            :used,
            :detail
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          known_spells_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

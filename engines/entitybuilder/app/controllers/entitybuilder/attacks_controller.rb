# frozen_string_literal: false

require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class AttacksController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_attack,   only: [:show, :edit, :update, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

    # GET /attacks
    def index
      @attacks = @parent_object.attacks

      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /attacks/1
    def show
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /attacks/new
    def new
      @attack = @parent_object.attacks.new
      @attack.sort_order = @parent_object.attacks.size

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /attacks/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    # POST /attacks
    def create
      @attack = @parent_object.attacks.new(attack_params)

      respond_to do |format|
        if @attack.save
          format.html { redirect_to attack_path(@parent_object, @attack), notice: 'attack was successfully added.' }
          format.json { render json: @attack, status: :created, location: @attack }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @attack.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /attacks/1
    def update
      respond_to do |format|
        if @attack.update(attack_params)
          format.html { redirect_to attack_path(@parent_object, @attack), notice: "#{@attack.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@attack.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @attack.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to attack_path(@parent_object, @attack), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /attacks/1
    def destroy
      @attack.destroy

      respond_to do |format|
        format.html { redirect_to attacks_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_attack
        @attack = @parent_object.attacks.find(params[:id])
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Attack Tutorial')
      end

      # Only allow a trusted parameter "white list" through.
      def attack_params
        params.require(:attack).permit(
            :entity_id,
            :sort_order,
            :name,
            :description,
            :attack_type,
            :attack_range,
            :attack_ability_score,
            :attack_dice,
            :attack_bonus,
            :attack_misc_modifier,
            :damage_ability_score,
            :damage_dice,
            :damage_bonus,
            :damage_misc_modifier,
            :critical_range,
            :proficient,
            :damage_type,
            :critical_damage_ability_score,
            :critical_damage_dice,
            :critical_damage_bonus,
            :critical_damage_misc_modifier,
            :special_damage_ability_score,
            :special_damage_dice,
            :special_damage_bonus,
            :special_damage_misc_modifier,
            :special_damage_name
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          attacks_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

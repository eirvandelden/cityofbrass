# frozen_string_literal: false

require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class SkillsController < ApplicationController
    include ApplicationHelper

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_skill, only: [:show, :edit, :update, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

    # GET /skills
    def index
      @skills = @parent_object.skills

      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /skills/1
    def show
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /skills/new
    def new
      @skill = @parent_object.skills.new
      @skill.sort_order = @parent_object.skills.size

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    def new_core_skill
      @skill = @parent_object.skills.new
      @skill.sort_order = @parent_object.skills.size

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /skills/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    # POST /skills
    def create
      @skill = @parent_object.skills.new(skill_params)
      respond_to do |format|
        if @skill.save
          format.html { redirect_to skill_path(@parent_object, @skill), notice: 'skill was successfully added.' }
          format.json { render json: @skill, status: :created, location: @skill }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @skill.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def create_core_skill

      @skill = @parent_object.skills.new(skill_params)
      core_skill = CoreRules::Entity.core_skill(@parent_object.core_rules, @skill.name)
      puts "========================="
      puts core_skill['ranks']
      puts core_skill['ability_score']

      @skill.ranks         = core_skill['ranks']
      @skill.ability_score = core_skill['ability_score']

      respond_to do |format|
        if @skill.save(:validate => false)
          format.html { redirect_to skill_path(@parent_object, @skill), notice: 'skill was successfully added.' }
          format.json { render json: @skill, status: :created, location: @skill }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @skill.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /skills/1
    def update
      respond_to do |format|
        if @skill.update(skill_params)
          format.html { redirect_to skill_path(@parent_object, @skill), notice: "#{@skill.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@skill.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @skill.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to skill_path(@parent_object, @skill), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /skills/1
    def destroy
      @skill.destroy

      respond_to do |format|
        format.html { redirect_to skills_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_skill
        @skill = @parent_object.skills.find(params[:id])
        @modifier_parent_object = @skill
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Skill Tutorial')
      end

      # Only allow a trusted parameter "white list" through.
      def skill_params
        params.require(:skill).permit(
            :entity_id,
            :sort_order,
            :name,
            :description,
            :bonus,
            :class_skill,
            :ability_score,
            :ranks,
            :misc_modifier,
            :dice,
            :proficient
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          skills_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

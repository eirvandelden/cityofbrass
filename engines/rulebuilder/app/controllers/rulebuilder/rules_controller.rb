# frozen_string_literal: false

require_dependency "rulebuilder/application_controller"

module Rulebuilder
  class RulesController < ApplicationController

    # GET /rules
    def index
      if (current_user.is_free?) && (@type.include?"Resident")
        @sub = "#{current_user.resident.resident_rules.count} / #{Quota.limit(current_user, @type)}"
      end
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /rules/1
    def show
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /rules/new
    def new
      @rule = klass.new
      @rule.resident_id = current_user.resident.id if @type.include?"Resident"
      @rule.core_rules = params[:core_rules]
      @rule.rule_type = params[:rule_type]

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /rules/1/edit
    def edit
      @rule.build_gallery_image_join if @rule.gallery_image_join.nil?

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # POST /rules
    def create
      @rule = klass.new (rule_params)
      @rule.resident_id = current_user.resident.id if @type.include?"Resident"
      @rule.is_shared = true

      respond_to do |format|
        if @rule.save
          format.html { redirect_to edit_polymorphic_path(@rule), notice: @rule.name + ' was successfully created.' }
          format.json { render json: @rule, status: :created, location: @rule }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @rule.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /rules/1
    def update
      respond_to do |format|
        if @rule.update(rule_params)
          format.html { redirect_to edit_polymorphic_path(@rule) }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@rule.name} has been updated." }
        else
          format.html { render action: 'edit' }
          format.json { render json: @rule.errors, status: :unprocessable_rule }
          format.js
        end
      end
    end

    # GET /rules/1/:options
    def options
    end

    # DELETE /rules/1
    def destroy
      respond_to do |format|
        if @rule.update(rule_params)
          @rule.destroy
          format.html { redirect_to polymorphic_path(@type.tableize) }
        else
          format.html { render action: 'options' }
        end
      end
    end

    private

      def klass
        "Rulebuilder::#{@type}".constantize
      end

      # Only allow a trusted parameter "white list" through.
      def rule_params
        params.require(@type.underscore.to_sym).permit(
          :resident_id,
          :parent_id,
          :core_rules,
          :rule_type,
          :shared,
          :name,
          :short_description,
          :full_description,
          :publisher,
          :source,
          :is_3pp,
          :tag_list,
          :category_list,
          :prerequisites,
          :benefit,
          :normal,
          :special,
          gallery_image_join_attributes: [:id, :image_id, :_destroy]
        )
      end

  end
end

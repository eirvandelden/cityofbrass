# frozen_string_literal: false

require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class LinkedRulesController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization, except: [:show]
    before_action :set_linked_rule,  only: [:show, :edit, :update, :destroy]
    before_action :set_core_faq,     only: [:index, :create, :update]
    before_action :set_rule_type,    only: [:index, :new, :update_list]
    before_action :set_linked_rules, only: [:index, :update_list]
    before_action :set_rule_options, only: [:new, :create]

    # GET /linked_rules
    def index
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /linked_rules/1
    def show
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /linked_rules/new
    def new
      @linked_rule = @parent_object.linked_rules.new
      @linked_rule.sort_order = @parent_object.linked_rules.size

      if params[:type] == 'new'
        @linked_rule.rule = Rulebuilder::Rule.new
        @linked_rule.rule.type = base_type
        @linked_rule.rule.resident_id = @parent_object.resident_id
        @linked_rule.rule.core_rules = @parent_object.core_rules
        @linked_rule.rule.rule_type = params[:rule_type]
      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /linked_rules/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    # POST /linked_rules
    def create
      @linked_rule = @parent_object.linked_rules.new(linked_rule_and_rule_params)

      if params[:type] == 'new'
        @linked_rule.build_rule(linked_rule_and_rule_params[:rule_attributes])
        @linked_rule.rule.type = base_type
        @linked_rule.rule.resident_id = @parent_object.resident_id
        @linked_rule.rule.core_rules = @parent_object.core_rules
        @linked_rule.rule.rule_type = params[:rule_type]
      end

      respond_to do |format|
        if @linked_rule.save
          params[:rule_type] = params[:rule_type]
          @linked_rules = @parent_object.linked_rules.joins(:rule).rule_type_filter(params[:rule_type])
          format.html { redirect_to linked_rule_path(@parent_object, @linked_rule), notice: 'linked_rule was successfully added.' }
          format.json { render json: @linked_rule, status: :created, location: @linked_rule }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @linked_rule.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /linked_rules/1
    def update

      lr_params =  @linked_rule.rule.can_edit?(current_user, admin_signed_in?, @linked_rule.rule.type) ? linked_rule_and_rule_params : linked_rule_params

      respond_to do |format|
        if @linked_rule.update(lr_params)
          format.html { redirect_to linked_rule_path(@parent_object, @linked_rule), notice: "#{@linked_rule.rule.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@linked_rule.rule.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @linked_rule.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to linked_rule_path(@parent_object, @linked_rule), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /linked_rules/1
    def destroy
      @linked_rule.destroy

      respond_to do |format|
        format.html { redirect_to linked_rules_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def base_type
        base_type = "Rulebuilder::ResidentRule"
        base_type = "Rulebuilder::StockRule" if @parent_object.type.include?"Stock"
        base_type = "Rulebuilder::ProprietaryRule" if @parent_object.type.include?"Proprietary"
        return base_type
      end

      def set_linked_rule
        @linked_rule = @parent_object.linked_rules.joins(:rule).find(params[:id])
        @modifier_parent_object = @linked_rule
        @linked_rules = @parent_object.linked_rules.joins(:rule).rule_type_filter(@linked_rule.rule.rule_type)
        params[:rule_type] = params[:rule_type] ||= @linked_rule.rule.rule_type
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Linked Rule Tutorial')
      end

      def set_rule_type
        rule_type = params[:rule_type].present? ? params[:rule_type].capitalize : ""
        @rule_type = (CoreRules::Rule.rule_types(@parent_object.core_rules).include?rule_type) ? rule_type : nil
        if @rule_type.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_linked_rules
        @linked_rules = @parent_object.linked_rules.joins(:rule).rule_type_filter(@rule_type)
      end

      def set_rule_options
        if params[:type] == "stock" && CoreRules.stock?(@parent_object.core_rules)
          @rule_options = Rulebuilder::StockRule.basic.order_name.core_rules_filter(@parent_object.core_rules).rule_type_filter(@rule_type).shared
        elsif params[:type] == "proprietary" && admin_signed_in?
          @rule_options = Rulebuilder::ProprietaryRule.basic.order_name.core_rules_filter(@parent_object.core_rules).rule_type_filter(@rule_type).shared
        elsif params[:type] == "resident"
          @rule_options = @parent_object.resident.resident_rules.basic.core_rules_filter(@parent_object.core_rules).rule_type_filter(@rule_type).shared
        end
      end

      # Only allow a trusted parameter "white list" through.
      def linked_rule_params
        params.require(:linked_rule).permit(
            :entity_id,
            :sort_order,
            :rule_id,
            :detail
          )
      end

      def linked_rule_and_rule_params
        params.require(:linked_rule).permit(
            :entity_id,
            :sort_order,
            :rule_id,
            :detail,
            rule_attributes: [
              :id,
              :parent_id,
              :is_shared,
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
              :special
            ]
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          linked_rules_attributes: [
              :id,
              :rule_type,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

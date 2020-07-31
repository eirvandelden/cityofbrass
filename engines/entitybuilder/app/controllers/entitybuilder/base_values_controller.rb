# frozen_string_literal: false

require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class BaseValuesController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_base_value, only: [:show, :edit, :update, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

    # GET /base_values
    def index
      @base_values = @parent_object.base_values

      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /base_values/1
    def show
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /base_values/new
    def new
      @base_value = @parent_object.base_values.new
      @base_value.sort_order = @parent_object.base_values.size

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /base_values/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    # POST /base_values
    def create
      @base_value = @parent_object.base_values.new(base_value_params)

      respond_to do |format|
        if @base_value.save
          format.html { redirect_to base_value_path(@parent_object, @base_value), notice: 'base_value was successfully added.' }
          format.json { render json: @base_value, status: :created, location: @base_value }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @base_value.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /base_values/1
    def update
      respond_to do |format|
        if @base_value.update(base_value_params)
          format.html { redirect_to base_value_path(@parent_object, @base_value), notice: "#{@base_value.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@base_value.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @base_value.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to base_value_path(@parent_object, @base_value), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /base_values/1
    def destroy
      @base_value.destroy

      respond_to do |format|
        format.html { redirect_to base_values_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_base_value
        @base_value = @parent_object.base_values.find(params[:id])
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Base Value Tutorial')
      end

      # Only allow a trusted parameter "white list" through.
      def base_value_params
        params.require(:base_value).permit(
            :entity_id,
            :sort_order,
            :name,
            :description,
            :value,
            :dice
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          base_values_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

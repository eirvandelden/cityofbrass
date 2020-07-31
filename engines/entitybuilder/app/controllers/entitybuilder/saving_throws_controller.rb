# frozen_string_literal: false

require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class SavingThrowsController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_saving_throw, only: [:show, :edit, :update, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

    # GET /saving_throws
    def index
      @saving_throws = @parent_object.saving_throws
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /saving_throws/1
    def show
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /saving_throws/new
    def new
      @saving_throw = @parent_object.saving_throws.new
      @saving_throw.sort_order = @parent_object.saving_throws.size

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /saving_throws/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    # POST /saving_throws
    def create
      @saving_throw = @parent_object.saving_throws.new(saving_throw_params)
      respond_to do |format|
        if @saving_throw.save
          format.html { redirect_to saving_throw_path(@parent_object, @saving_throw), notice: 'saving_throw was successfully added.' }
          format.json { render json: @saving_throw, status: :created, location: @saving_throw }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @saving_throw.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /saving_throws/1
    def update
      respond_to do |format|
        if @saving_throw.update(saving_throw_params)
          format.html { redirect_to saving_throw_path(@parent_object, @saving_throw), notice: "#{@saving_throw.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@saving_throw.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @saving_throw.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to saving_throw_path(@parent_object, @saving_throw), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /saving_throws/1
    def destroy
      @saving_throw.destroy

      respond_to do |format|
        format.html { redirect_to saving_throws_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_saving_throw
        @saving_throw = @parent_object.saving_throws.find(params[:id])
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Saving Throw Tutorial')
      end

      # Only allow a trusted parameter "white list" through.
      def saving_throw_params
        params.require(:saving_throw).permit(
            :entity_id,
            :sort_order,
            :name,
            :description,
            :bonus,
            :base,
            :dice,
            :ability_score,
            :misc_modifier,
            :proficient
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          saving_throws_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

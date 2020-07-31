# frozen_string_literal: false

require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class DescriptorsController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_descriptor, only: [:show, :edit, :update, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

    # GET /descriptors
    def index
      @descriptors = @parent_object.descriptors

      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /descriptors/1
    def show
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /descriptors/new
    def new
      @descriptor = @parent_object.descriptors.new
      @descriptor.sort_order = @parent_object.descriptors.size

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /descriptors/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    # POST /descriptors
    def create
      @descriptor = @parent_object.descriptors.new(descriptor_params)

      respond_to do |format|
        if @descriptor.save
          format.html { redirect_to descriptor_path(@parent_object, @descriptor), notice: 'descriptor was successfully added.' }
          format.json { render json: @descriptor, status: :created, location: @descriptor }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @descriptor.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /descriptors/1
    def update
      respond_to do |format|
        if @descriptor.update(descriptor_params)
          format.html { redirect_to descriptor_path(@parent_object, @descriptor), notice: "#{@descriptor.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@descriptor.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @descriptor.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to descriptor_path(@parent_object, @descriptor), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /descriptors/1
    def destroy
      @descriptor.destroy

      respond_to do |format|
        format.html { redirect_to descriptors_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_descriptor
        @descriptor = @parent_object.descriptors.find(params[:id])
        @modifier_parent_object = @descriptor
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Descriptor Tutorial')
      end

      # Only allow a trusted parameter "white list" through.
      def descriptor_params
        params.require(:descriptor).permit(
            :entity_id,
            :sort_order,
            :name,
            :description,
            :is_private
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          descriptors_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

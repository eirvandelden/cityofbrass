# frozen_string_literal: false

require_dependency "campaignmanager/application_controller"

module Campaignmanager
  class FeaturesController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_feature, only: [:show, :edit, :update, :destroy]

    # GET /features
    def index
      @features = @parent_object.features
    end

    # GET /features/1
    def show
    end

    # GET /features/new/text
    def new_feature_type
      sort_order = 0
      sort_order = @parent_object.features.order_sort_order.last.sort_order.to_i+1 unless @parent_object.features.order_sort_order.last.nil?

      @feature = @parent_object.features.new
      @feature.sort_order = sort_order
      @feature.feature_type = params[:new_feature_type]
    end

    # GET /features/1/edit
    def edit
    end

    # POST /features
    def create
      @feature = @parent_object.features.new(feature_params)

      respond_to do |format|
        if @feature.save
          format.html { redirect_to feature_path(@parent_object, @feature), notice: 'feature was successfully added.' }
          format.json { render json: @feature, status: :created, location: @feature }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @feature.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /features/1
    def update
      respond_to do |format|
        if @feature.update(feature_params)
          format.html { redirect_to feature_path(@parent_object, @feature), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @feature.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to feature_path(@parent_object, @feature), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /features/1
    def destroy
      @feature.destroy

      respond_to do |format|
        format.html { redirect_to features_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def parent_type
        #return the last match
        parent_type = "campaign"
        params.each do |key, value|
          if key.include?"_id"
            parent_type = key.gsub('_id', '')
          end
        end
        return parent_type
      end

      def set_feature
        @feature = @parent_object.features.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def feature_params
        params.require(:feature).permit(
            :featureable_id,
            :featureable_type,
            :sort_order,
            :feature_type,
            :feature_label,
            :feature_text,
            :search_tags,
            :record_type
          )
      end

      def entity_params
        params.require(@parent_type).permit(
          features_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

# frozen_string_literal: false

require_dependency "worldbuilder/application_controller"

module Worldbuilder
  class SectionsController < ApplicationController

    before_action :authenticate_user!
    before_action :set_type
    before_action :set_district
    before_action :set_parent_object
    before_action :check_authorization
    before_action :set_section, only: [:show, :edit, :update, :destroy]

    # GET /sections
    def index
      @sections = @parent_object.sections
    end

    # GET /sections/1
    def show
    end

    # GET /sections/new/text
    def new
      if Worldbuilder::Section::OPTIONS.include?params[:section_type]
        sort_order = 0
        sort_order = @parent_object.sections.order_sort_order.last.sort_order.to_i+1 unless @parent_object.sections.order_sort_order.last.nil?

        @section = @parent_object.sections.new
        @section.sort_order = sort_order
        @section.section_type = params[:section_type]
        if @section.section_type == 'tag'
          @section.record_type = 'Worldbuilder'
        end
      else
        render :nothing => true, :status => 405
      end
    end

    # GET /sections/1/edit
    def edit
    end

    # POST /sections
    def create
      @section = @parent_object.sections.new(section_params)

      respond_to do |format|
        if @section.save
          format.html { redirect_to section_path(@parent_object, @section), notice: 'section was successfully added.' }
          format.json { render json: @section, status: :created, location: @section }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @section.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /sections/1
    def update
      respond_to do |format|
        if @section.update(section_params)
          format.html { redirect_to section_path(@parent_object, @section), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @section.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(entity_params)
          format.html { redirect_to section_path(@parent_object, @section), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /sections/1
    def destroy
      @section.destroy

      respond_to do |format|
        format.html { redirect_to sections_path(@parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_type
        @type = type
      end

      def type
        parent_type = "district"
        params.each do |key, value|
          if key.include?"_id"
            parent_type = key.gsub('_id', '')
          end
        end
        return parent_type
      end

      def set_district
        if @type == "district"
          @district = District.find_by_id(params[:district_id]) unless params[:district_id].nil?
        else
          @district = District.find_by_slug(params[:district_id]) unless params[:district_id].nil?
        end
      end

      def set_parent_object
        if @type == "district"
          @parent_object = @district
        else
          @parent_object = @district.send("#{@type.tableize}").find_by_id(params["#{@type}_id"])
        end

        if @parent_object.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_section
        @section = @parent_object.sections.find(params[:id])
      end

      def check_authorization
        unless @district.can_edit?(current_user, admin_signed_in?)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      # Only allow a trusted parameter "white list" through.
      def section_params
        params.require(:section).permit(
            :sectionable_id,
            :sectionable_type,
            :sort_order,
            :section_type,
            :header,
            :content,
            :section_style,
            :search_tags,
            :record_type
          )
      end

      def entity_params
        params.require(@type).permit(
          sections_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

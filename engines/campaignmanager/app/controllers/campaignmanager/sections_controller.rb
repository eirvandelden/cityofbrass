require_dependency "campaignmanager/application_controller"

module Campaignmanager
  class SectionsController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_section, only: [:show, :edit, :update, :destroy]

    # GET /sections
    def index
      @sections = @parent_object.sections
    end

    # GET /sections/1
    def show
    end

    # GET /sections/new/text
    def new_section_type
      sort_order = 0
      sort_order = @parent_object.sections.order_sort_order.last.sort_order.to_i+1 unless @parent_object.sections.order_sort_order.last.nil?

      @section = @parent_object.sections.new
      @section.sort_order = sort_order
      @section.section_type = params[:new_section_type]
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

      def set_section
        @section = @parent_object.sections.find(params[:id])
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
        params.require(@parent_type).permit(
          sections_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

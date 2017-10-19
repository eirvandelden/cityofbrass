require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class ModifiersController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :set_modifier_parent_type,    except: [:index]
    before_action :set_modifier_parent_object,  except: [:index]
    before_action :check_parent_authorization
    before_action :set_modifier,                only: [:show, :edit, :update, :destroy]
    before_action :set_core_faq, only: [:index, :create, :update]

    # GET /modifiers
    def index
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /modifiers/1
    def show
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /modifiers/new
    def new
      @modifier = @modifier_parent_object.modifiers.new
      @modifier.sort_order = @parent_object.modifiers.size
      @modifier.entity = @parent_object

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /modifiers/1/edit
    def edit
      respond_to do |format|
          format.html
          format.js
      end
    end

    # POST /modifiers
    def create
      @modifier = @modifier_parent_object.modifiers.new(modifier_params)
      @modifier.entity = @parent_object

      respond_to do |format|
        if @modifier.save
          format.html { redirect_to modifier_path(@modifier_parent_object, @modifier), notice: 'modifier was successfully added.' }
          format.json { render json: @modifier, status: :created, location: @modifier }
          format.js
        else
          format.html { render action: "new" }
          format.json { render json: @modifier.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /modifiers/1
    def update
      respond_to do |format|
        if @modifier.update(modifier_params)
          format.html { redirect_to modifier_path(@modifier_parent_object, @modifier), notice: "#{@modifier_parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@modifier_parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @modifier.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update_list
      respond_to do |format|
        if @parent_object.update(type_params)
          format.html { redirect_to modifier_path(@parent_object, @modifier), notice: "#{@parent_object.name} was successfully updated." }
          format.json { head :no_content }
          format.js   { flash.now[:notice] = "#{@parent_object.name} has been updated." }
        else
          format.html { render action: "edit" }
          format.json { render json: @parent_object.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /modifiers/1
    def destroy
      @modifier.destroy

      respond_to do |format|
        format.html { redirect_to modifiers_path(@modifier_parent_object) }
        format.json { head :no_content }
        format.js
      end
    end

    private

      def set_modifier_parent_type
        @modifier_parent_type = modifier_parent_type
      end

      def modifier_parent_type
        params.each do |key, value|
         if key.include?"_id"
           unless key.include?"character_id" or key.include?"creature_id" or key.include?"npc_id"
             return key.gsub('_id', '')
           end
         end
        end
      end

      def set_modifier_parent_object
        @modifier_parent_object = @parent_object.send("#{@modifier_parent_type.tableize}").find_by_id(params["#{@modifier_parent_type}_id"])
        if @modifier_parent_object.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_modifier
        @modifier = @modifier_parent_object.modifiers.find(params[:id])
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('EB Modifier Tutorial')
      end

      # Only allow a trusted parameter "white list" through.
      def modifier_params
        params.require(:modifier).permit(
            :modifierable_id,
            :modifierable_type,
            :entity_id,
            :sort_order,
            :category,
            :item,
            :value,
            :dice
          )
      end

      def type_params
        params.require(@modifier_parent_object).permit(
          modifiers_attributes: [
              :id,
              :sort_order,
              :_destroy
            ]
          )
      end
  end
end

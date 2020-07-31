# frozen_string_literal: false

require_dependency "storybuilder/application_controller"

module Storybuilder
  class AdventuresController < ApplicationController

    # GET /adventures
    # GET /adventures.json
    def index
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /adventures/1
    def show
      @adventure_children = @adventure.children.to_a.sort_by! { |ae| ae.name.downcase }
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /adventures/1
    def campaign
      respond_to do |format|
        format.html
      end
    end

    # GET /adventures/new
    def new
      @adventure = klass.new(parent_id: params[:parent])
      @adventure.resident_id = current_user.resident.id if @type.include?"Resident"
      unless @adventure.parent_id.blank?
        @parent = klass.find_by_id(@adventure.parent_id)
        @adventure.build_menu_item_join(:menu_item_id => @parent.menu_item_join.menu_item_id) unless @parent.menu_item_join.nil?
      end
      @adventure.build_menu_item_join if @adventure.menu_item_join.nil?
      @adventure.build_gallery_image_join if @adventure.gallery_image_join.nil?
    end

    # GET /adventures/1/:edit
    def edit
      @adventure.build_menu_item_join if @adventure.menu_item_join.nil?
      @adventure.build_gallery_image_join if @adventure.gallery_image_join.nil?
    end

    # GET /adventures/1/:options
    def options
    end

    # POST /adventures
    # POST /adventures.json
    def create
      @adventure = klass.new(adventure_params)
      @adventure.resident_id = current_user.resident.id if @type.include?"Resident"
      @adventure.build_gallery_image_join if @adventure.gallery_image_join.nil?

      unless @adventure.parent_id.blank?
        @parent = klass.find_by_id(@adventure.parent_id)
        @adventure.build_menu_item_join(:menu_item_id => @parent.menu_item_join.menu_item_id) unless @parent.menu_item_join.nil?
      end

      respond_to do |format|
        if @adventure.save
          format.html { redirect_to edit_polymorphic_path(@adventure), notice: @adventure.name + ' was successfully created.' }
        else
          format.html { render action: 'new' }
        end
      end
    end

    # PATCH/PUT /adventures/1
    # PATCH/PUT /adventures/1.json
    def update
      respond_to do |format|
        if @adventure.update(adventure_params)
          format.html { redirect_to edit_polymorphic_path(@adventure) }
          format.js   { flash.now[:notice] = "#{@adventure.name} has been updated." }
        else
          format.html { render action: 'edit' }
          format.js
        end
      end
    end

    # DELETE /adventures/1
    # DELETE /adventures/1.json
    def destroy
      respond_to do |format|
        if @adventure.update(adventure_params)
          @adventure.destroy
          format.html { redirect_to polymorphic_path(@type.tableize) }
        else
          format.html { render action: 'options' }
        end
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.

      def klass
        return "Storybuilder::#{@type}".constantize
      end

      def can_show
        unless @adventure.can_show?(current_user, admin_signed_in?, @type)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      def can_edit
        unless @adventure.can_edit?(current_user, admin_signed_in?, @type)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      def check_authorization
        unless admin_signed_in?
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def adventure_params
        params.require(@type.underscore.to_sym).permit(
          :parent_id,
          :name,
          :slug, # <===== LEGACY / GET RID OF ME
          :page_label,
          :privacy,
          :core_rules,
          :short_description,
          :full_description,
          :name_confirmation,
          menu_item_join_attributes: [:id, :menu_item_id, :_destroy],
          gallery_image_join_attributes: [:id, :image_id, :_destroy]
        )
      end
  end
end

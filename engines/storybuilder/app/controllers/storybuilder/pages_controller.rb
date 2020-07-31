# frozen_string_literal: false

require_dependency "storybuilder/application_controller"

module Storybuilder
  class PagesController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization, except: [:show, :index]
    before_action :set_adventure

    before_action :set_page,          only: [:edit, :update, :options, :destroy]
    before_action :set_page_for_show, only: [:show]
    before_action :can_show,          only: [:show]
    before_action :set_core_faq,      only: [:new, :edit, :update]

    before_action :check_quota,       only: [:new, :create]

    # GET /pages
    # GET /pages.json
    def index
      if @parent_object.user.is_free?
        @sub = "#{@parent_object.pages.count} / #{Quota.limit(current_user, 'Page')}"
      end

      unless @adventure.can_edit?(current_user, admin_signed_in?, @parent_type)
        render template: 'errors/403', layout: 'layouts/application', status: 403
      end

      respond_to do |format|
        format.html { @pages = @parent_object.pages.search(params[:search]).short.order_name.page(params[:page]) }
        format.json { @pages = @parent_object.pages.order_name.short }
        format.js   { @pages = @parent_object.pages.search(params[:search]).short.order_name.page(params[:page]) }
      end
    end

    # GET /pages/1
    # GET /pages/1.json
    def show
    end

    # GET /pages/new
    def new
      @page = @parent_object.pages.new(parent_id: params[:parent_id])
      unless @page.parent_id.blank?
        @parent = @parent_object.pages.find_by_id(@page.parent_id)
        @page.build_menu_item_join(:menu_item_id => @parent.menu_item_join.menu_item_id) unless @parent.menu_item_join.nil?
      end
      @page.build_menu_item_join if @page.menu_item_join.nil?
      @page.build_gallery_image_join if @page.gallery_image_join.nil?
    end

    # GET /pages/1/:edit
    def edit
      @page.build_menu_item_join if @page.menu_item_join.nil?
      @page.build_gallery_image_join if @page.gallery_image_join.nil?
    end

    # GET /pages/1/:options
    def options
    end

    # POST /pages
    # POST /pages.json
    def create
      @page = @parent_object.pages.new(page_params)
      @page.build_gallery_image_join if @page.gallery_image_join.nil?

      unless @page.parent_id.blank?
        @parent = @parent_object.pages.find_by_id(@page.parent_id)
        @page.build_menu_item_join(:menu_item_id => @parent.menu_item_join.menu_item_id) unless @parent.menu_item_join.nil?
      end

      respond_to do |format|
        if @page.save
          format.html { redirect_to storybuilder.edit_polymorphic_path([@parent_object, @page]), notice: @page.name + ' was successfully created.' }
        else
          format.html { render action: 'new' }
        end
      end
    end

    # PATCH/PUT /pages/1
    # PATCH/PUT /pages/1.json
    def update
      respond_to do |format|
        if @page.update(page_params)
          format.html { redirect_to storybuilder.edit_polymorphic_path([@parent_object, @page]) }
          format.js   { flash.now[:notice] = "#{@page.name} has been updated." }
        else
          format.html { render action: 'edit' }
          format.js
        end
      end
    end

    # DELETE /pages/1
    # DELETE /pages/1.json
    def destroy
      respond_to do |format|
        if @page.update(page_params)
          @page.destroy
          format.html { redirect_to storybuilder.polymorphic_path([@parent_object, :pages]) }
        else
          format.html { render action: 'options' }
        end
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def params_id
        params_id = params[:page_id] ||= params[:id]
      end

      def set_adventure
        @adventure = @parent_object
        if @parent_object.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_page
        @page = @parent_object.pages.find_by_id(params_id) unless params_id.nil?
        if @page.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_page_for_show
        @page = @parent_object.pages.includes([:features, :sections, :menu_item_join, :gallery_image, :entities]).find_by_id(params_id) unless params_id.nil?
        if @page.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_core_faq
        @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('SB Page Tutorial')
      end

      def can_show
        unless @page.can_show?(current_user, admin_signed_in?)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def page_params
        params.require(:page).permit(
          :resident_id,
          :parent_id,
          :name,
          :slug,
          :page_label,
          :privacy,
          :player_handout,
          :tag_list,
          :short_description,
          :full_description,
          :sort_weight,
          :name_confirmation,
          menu_item_join_attributes: [:id, :menu_item_id, :_destroy],
          gallery_image_join_attributes: [:id, :image_id, :_destroy]
        )
      end

  end
end

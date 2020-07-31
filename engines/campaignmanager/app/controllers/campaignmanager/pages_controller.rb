# frozen_string_literal: false

require_dependency "campaignmanager/application_controller"

module Campaignmanager
  class PagesController < ApplicationController

    before_action :authenticate_user!, except: [:show, :index]
    before_action :check_user_status,  except: [:show, :index]

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization, except: [:show, :index]
    before_action :set_campaign

    before_action :set_type
    before_action :set_page,          only: [:edit, :update, :options, :destroy]
    before_action :set_page_for_show, only: [:show]
    before_action :can_show,          only: [:show]

    before_action :check_quota,           only: [:new, :create]

    # GET /pages
    # GET /pages.json
    def index
      if @parent_object.user.is_free?
        @sub = "#{@parent_object.pages.count} / #{Quota.limit(current_user, 'Page')}"
      end

      if ('Campaignmanager::GameMasterNote'.include?@type) && user_signed_in? && !(current_user.resident == @parent_object.resident)
        render template: 'errors/404', layout: 'layouts/application', status: 404
      end
      unless @campaign.can_show?(current_user, admin_signed_in?, @type)
        render template: 'errors/403', layout: 'layouts/application', status: 403
      end

      respond_to do |format|
        format.html { @pages = @parent_object.send("#{@type.tableize}").short.page(params[:page]) }
        format.json { @pages = @parent_object.send("#{@type.tableize}").short }
      end
    end

    # GET /pages/1
    # GET /pages/1.json
    def show
    end

    # GET /pages/new
    def new
      @page = @campaign.send("#{@type.tableize}").new(parent_id: params[:parent_id])
      unless @page.parent_id.blank?
        @parent = type_class.find_by_id(@page.parent_id)
      end
      @page.build_gallery_image_join if @page.gallery_image_join.nil?
    end

    # GET /pages/1/:edit
    def edit
      @page.build_gallery_image_join if @page.gallery_image_join.nil?
    end

    # GET /pages/1/:options
    def options
    end

    # POST /pages
    # POST /pages.json
    def create
      @page = @campaign.send("#{@type.tableize}").new(page_params)
      @page.build_gallery_image_join if @page.gallery_image_join.nil?

      unless @page.parent_id.blank?
        @parent = type_class.find_by_id(@page.parent_id)
      end

      if current_user.is_free?
        unless Campaignmanager::Campaign::PRIVACY_OPTIONS_FREE.include? @page.privacy
          @page.privacy = 'invalid'
        end
      end

      respond_to do |format|
        if @page.save
          format.html { redirect_to sti_edit_page_path(@page), notice: @page.name + ' was successfully created.' }
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
          format.html { redirect_to sti_edit_page_path(@page) }
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
          format.html { redirect_to sti_pages_path }
        else
          format.html { render action: 'options' }
        end
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_type
        @type = type
      end

      def type
        params[:type] || "Page"
      end

      def type_class
        type_class = "Campaignmanager::#{type}".constantize
      end

      def params_id
        params_id = params["#{@type.underscore}_id"] ||= params[:id]
      end

      def set_campaign
        @campaign = @parent_object
        if @parent_object.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_page
        @page = @parent_object.send("#{@type.tableize}").find_by_id(params_id) unless params_id.nil?
        if @page.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_page_for_show
        @page = @parent_object.send("#{@type.tableize}").includes([:features, :sections]).find_by_id(params_id) unless params_id.nil?
        if @page.nil? || !@page.can_show?(current_user, admin_signed_in?, @type)
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def sti_edit_page_path(page)
        send "edit_#{@parent_type.underscore}_#{@type.underscore}_path", @parent_object, page
      end

      def sti_pages_path
        send "#{@parent_type.underscore}_#{@type.underscore.pluralize}_path"
      end

      def can_show
        unless @page.can_show?(current_user, admin_signed_in?, @type)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def page_params
        params.require(type.underscore.to_sym).permit(
          :resident_id,
          :type,
          :parent_id,
          :name,
          :slug,
          :page_label,
          :page_date,
          :privacy,
          :short_description,
          :full_description,
          :name_confirmation,
          gallery_image_join_attributes: [:id, :image_id, :_destroy]
        )
      end
  end
end

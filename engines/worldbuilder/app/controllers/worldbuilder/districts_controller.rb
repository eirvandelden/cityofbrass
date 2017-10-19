require_dependency "worldbuilder/application_controller"

module Worldbuilder
  class DistrictsController < ApplicationController

    include DistrictsHelper

    before_action :set_district_by_id,    only: [:edit, :update, :options, :destroy]
    before_action :set_district_by_slug,  only: [:show, :campaign]

    before_action :set_type
    before_action :set_campaign,          only: [:campaign]

    before_action :can_show,              only: [:show, :campaign]
    before_action :can_edit,            except: [:index, :show, :campaign, :new, :create]

    before_action :check_quota,           only: [:new, :create]

    # GET /districts
    def index
      privacy = ['Public']
      privacy << 'Residents' if user_signed_in?
      @districts = District.joins(:user).search(params[:search]).short.order_updated_at.page(params[:page]).where(privacy: privacy)
    end

    # GET /districts/1
    def show
    end

    # GET /districts/1
    def campaign
    end

    # GET /districts/new
    def new
      @district = current_user.resident.districts.build
      @district.build_gallery_image_join if @district.gallery_image_join.nil?
    end

    # GET /districts/1/edit
    def edit
      @district.build_gallery_image_join if @district.gallery_image_join.nil?
      @district.build_menu_item_join if @district.menu_item_join.nil?
    end

    # GET /districts/1/:options
    def options
    end

    # POST /districts
    def create
      @district = current_user.resident.districts.new(district_params)
      @district.build_gallery_image_join if @district.gallery_image_join.nil?

      if current_user.is_free?
        unless Worldbuilder::District::PRIVACY_OPTIONS_FREE.include? @district.privacy
          @district.privacy = 'invalid'
        end
      end

      respond_to do |format|
        if @district.save
          wb_district_mockup(@district)
          format.html { redirect_to district_path(@district.slug), notice: "#{@district.name} is ready for management!" }
        else
          format.html { render action: 'new' }
        end
      end
    end

    # PATCH/PUT /districts/1
    def update

      if current_user.is_free?
        unless Worldbuilder::District::PRIVACY_OPTIONS_FREE.include?(district_params[:privacy])
          params[:district][:privacy] = 'invalid'
        end
      end

      respond_to do |format|
        if @district.update(district_params)
          format.html { redirect_to edit_district_path(@district) }
          format.js   { flash.now[:notice] = "#{@district.name} has been updated." }
        else
          format.html { render action: 'edit' }
          format.js
        end
      end
    end

    # DELETE /districts/1
    def destroy
      respond_to do |format|
        if @district.update(district_params)
          @district.destroy
          format.html { redirect_to main_app.resident_districts_path(@district.resident.slug) }
        else
          format.html { render action: 'options' }
        end
      end
    end

    private
      def set_type
        @type = 'District'
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_district_by_id
        params_id = params[:district_id] ||= params[:id]
        @district = District.joins(:user).find_by_id(params_id) unless params_id.nil?
        if @district.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_district_by_slug
        params_id = params[:district_id] ||= params[:id]
        @district = District.joins(:user).includes([:features, :sections, :menu_items, :contributors, :gallery_image]).find_by_slug(params_id) unless params_id.nil?
        if @district.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_campaign
        @campaign = Campaignmanager::Campaign.find_by_id(params[:campaign_id]) unless params[:campaign_id].nil?
        if @campaign.nil? || !@campaign.can_show?(current_user, admin_signed_in?)
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
        @resident = @campaign.resident
      end

      def can_show
        unless @district.can_show?(current_user, admin_signed_in?)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      def can_edit
        unless @district.can_edit?(current_user, admin_signed_in?)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      # Only allow a trusted parameter "white list" through.

    def district_params
      params.require(:district).permit(
        :name,
        :slug,
        :page_label,
        :privacy,
        :short_description,
        :full_description,
        :name_confirmation,
        menu_item_join_attributes: [:id, :menu_item_id, :_destroy],
        gallery_image_join_attributes: [:id, :image_id, :_destroy]
      )
    end
  end
end

require_dependency "campaignmanager/application_controller"

module Campaignmanager
  class CampaignsController < ApplicationController

    include CampaignsHelper

    before_action :authenticate_user!, except: [:show, :characters, :notables]
    before_action :check_user_status,  except: [:show, :characters, :notables]

    before_action :set_type
    before_action :set_campaign,          only: [:edit, :update, :options, :destroy]
    before_action :set_campaign_for_show, only: [:show]
    before_action :set_characters,        only: [:characters]
    before_action :set_notables,          only: [:notables]
    before_action :set_campaigns,         only: [:index]

    before_action :can_show,              only: [:show, :characters, :notables]
    before_action :can_edit,              only: [:edit, :update, :options, :destroy]

    before_action :check_quota,           only: [:new, :create]

    # GET /campaigns
    # GET /campaigns.js
    def index
      respond_to do |format|
        format.html
        format.js
      end
    end

    # GET /campaigns/1
    # GET /campaigns/1.json
    def show
      respond_to do |format|
        format.html
        format.json
      end
    end

    # GET /campaigns/1
    # GET /campaigns/1.json
    def characters
      respond_to do |format|
        format.html
      end
    end

    # GET /campaigns/1
    # GET /campaigns/1.json
    def notables
      respond_to do |format|
        format.html
      end
    end

    # GET /campaigns/new
    def new
      @campaign = Campaign.new
      @campaign.resident_id = current_user.resident.id
      @campaign.build_gallery_image_join if @campaign.gallery_image_join.nil?
    end

    # GET /campaigns/1/:edit
    def edit
      @campaign.build_gallery_image_join if @campaign.gallery_image_join.nil?
    end

    # GET /campaigns/1/:options
    def options
    end

    # POST /campaigns
    # POST /campaigns.json
    def create
      @campaign = Campaign.new(campaign_params)
      @campaign.resident_id = current_user.resident.id
      @campaign.build_gallery_image_join if @campaign.gallery_image_join.nil?

      if current_user.is_free?
        unless Campaignmanager::Campaign::PRIVACY_OPTIONS_FREE.include? @campaign.privacy
          @campaign.privacy = 'invalid'
        end
      end

      respond_to do |format|
        if @campaign.save
          cm_new_activeplay_virtual_table(@campaign) if @campaign.activeplay.blank?
          format.html { redirect_to edit_campaign_path(@campaign), notice: @campaign.name + ' was successfully created.' }
        else
          format.html { render action: 'new' }
        end
      end
    end

    # PATCH/PUT /campaigns/1
    # PATCH/PUT /campaigns/1.json
    def update

      if current_user.is_free?
        unless Campaignmanager::Campaign::PRIVACY_OPTIONS_FREE.include?(campaign_params[:privacy])
          params[:campaign][:privacy] = 'invalid'
        end
      end

      respond_to do |format|
        if @campaign.update(campaign_params)
          cm_new_activeplay_virtual_table(@campaign) if @campaign.activeplay.blank?
          format.html { redirect_to edit_campaign_path(@campaign) }
          format.js   { flash.now[:notice] = "#{@campaign.name} has been updated." }
        else
          format.html { render action: 'edit' }
          format.js
        end
      end
    end

    # DELETE /campaigns/1
    # DELETE /campaigns/1.json
    def destroy
      respond_to do |format|
        if @campaign.update(campaign_params)
          @campaign.destroy
          format.html { redirect_to main_app.resident_campaigns_path(@campaign.resident.slug) }
        else
          format.html { render action: 'options' }
        end
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def params_id
        return params[:campaign_id] ||= params[:id]
      end

      def set_type
        @type = 'Campaign'
      end

      def set_campaigns
        privacy = ['Public']
        privacy << 'Residents' if user_signed_in?
        @campaigns = Campaign.joins(:user).includes(:resident).search(params[:search]).short.order_updated_at.page(params[:page]).where(privacy: privacy)
      end

      def set_campaign
        @campaign = Campaign.joins(:user).find_by_id(params_id)
        if @campaign.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
        @parent_object = @campaign
      end

      def set_campaign_for_show
        @campaign = Campaign.joins(:user).includes([:features, :sections, :player_residents, :adventure, :district]).find_by_id(params_id)
        if @campaign.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end

        if user_signed_in? && current_user.resident
          player_resident_id_list = @campaign.player_residents.pluck(:id);
          @pending_affiliations = current_user.resident.pending_affiliations.where('affiliations.affiliate_id': player_resident_id_list)
          @requested_affiliations = current_user.resident.requested_affiliations.where('affiliations.affiliate_id': player_resident_id_list)
          @blocked_affiliations = current_user.resident.blocked_affiliations.where('affiliations.affiliate_id': player_resident_id_list)
          @affiliates = current_user.resident.affiliates.where('affiliations.affiliate_id': player_resident_id_list)

          pending_affiliation_list = @pending_affiliations.collect(&:id).uniq
          requested_affiliation_list = @requested_affiliations.collect(&:id).uniq
          blocked_affiliation_list = @blocked_affiliations.collect(&:id).uniq
          affiliate_list = @affiliates.collect(&:id).uniq
          set_list = pending_affiliation_list + requested_affiliation_list + affiliate_list + blocked_affiliation_list + [current_user.resident.id]

          @not_affiliates = @campaign.player_residents.where.not('residents.id': set_list)
        else
          @players = @campaign.player_residents
        end

      end

      def set_characters
        @campaign = Campaign.joins(:user).includes([:characters, :class_levels]).short.find_by_id(params_id)
        if @campaign.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def set_notables
        @campaign = Campaign.joins(:user).includes([:entities]).short.find_by_id(params_id)
        if @campaign.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def can_show
        unless @campaign.can_show?(current_user, admin_signed_in?)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      def can_edit
        unless @campaign.can_edit?(current_user, admin_signed_in?)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def campaign_params
        params.require(:campaign).permit(
          :name,
          :slug,
          :page_label,
          :privacy,
          :core_rules,
          :district_id,
          :adventure_id,
          :short_description,
          :full_description,
          :name_confirmation,
          gallery_image_join_attributes: [:id, :image_id, :_destroy]
        )
      end
  end
end

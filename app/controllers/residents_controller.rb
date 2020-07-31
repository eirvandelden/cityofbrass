# frozen_string_literal: false

class ResidentsController < ApplicationController

  before_action :authenticate_user!
  before_action :check_user_status

  before_action :set_resident_by_slug, only: [:show, :campaigns, :districts]
  before_action :set_resident_by_id,   only: [:admin_update]
  before_action :set_resident,         only: [:edit, :update, :destroy]

  # GET /residents
  def index
    @residents = Resident.joins(:user).search(params[:search]).short.order_name.page(params[:page])
  end

  # GET /residents/1
  def show
    @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('Resident Show')

    if @resident.can_auth(current_user)
      @top_5_characters = @resident.top_5_characters
      @top_5_adventures = @resident.top_5_adventures

      @top_5_pending_affiliations = @resident.top_5_pending_affiliations
      @top_5_requested_affiliations = @resident.top_5_requested_affiliations
      @top_10_affiliates = @resident.top_10_affiliates
    end
    @top_5_campaigns = @resident.top_5_campaigns
    @top_5_districts = @resident.top_5_districts
  end

  # GET /residents/1
  def districts
    @districts = @resident.districts.short.page(params[:page])

    if @districts.blank?
      @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('WB District Index')
    end

    @wb_contributions = @resident.wb_contributions.page(params[:page]) if request.format == "html"

    @district_list = @resident.district_list if request.format == "json"

    respond_to do |format|
      format.html
      format.json
    end
  end

  def campaigns
    @cm_gm_campaigns = @resident.campaigns.short.page(params[:page])
    @cm_pc_campaigns = @resident.cm_pc_campaigns

    if @cm_gm_campaigns.blank? && @cm_pc_campaigns.blank?
      @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('CM Campaign Index')
    end
  end

  # GET /residents/new
  def new
    if current_user.resident.nil?
      @core_faq = Support::CoreFaq.joins(:faq).active.find_by_core_item('Resident New')
      @resident = current_user.build_resident
    else
      redirect_to root_path
    end
  end

  # GET /residents/1/:edit
  def edit
    @resident.build_gallery_image_join if @resident.gallery_image_join.nil?
  end

  # POST /residents
  def create
    @resident = current_user.build_resident(resident_params)

    respond_to do |format|
      if @resident.save
        format.html { redirect_to resident_path(@resident.slug), notice: @resident.name + ' has joined City of Brass!' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /residents/1
  def update
    respond_to do |format|
      if @resident.update(resident_params)
        format.js   { flash.now[:notice] = "#{@resident.name} has been updated." }
      else
        format.js
      end
    end
  end

  # PATCH/PUT /residents/1
  def admin_update
    respond_to do |format|
      if @resident.update(admin_resident_params)
        format.js   { flash.now[:notice] = "#{@resident.name} has been updated." }
      else
        format.js
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def params_id
      return params[:resident_id] ||= params[:id]
    end

    def set_resident
      @resident = current_user.resident
      if @resident.nil?
        redirect_to residents_path, notice: "Resident not found."
      end
    end

    def set_resident_by_id
      @resident = Resident.find_by_id(params[:id])
      if @resident.nil?
        redirect_to residents_path, notice: "Resident not found."
      end
    end

    def set_resident_by_slug
      @resident = Resident.joins(:user).includes([:gallery_image]).find_by_slug(params_id)
      if @resident.nil?
        redirect_to residents_path, notice: "Resident not found."
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resident_params
      params.require(:resident).permit(
        :name,
        :slug,
        :short_description,
        :full_description,
        gallery_image_join_attributes: [:id, :image_id, :_destroy]
      )
    end

    def admin_resident_params
      params.require(:resident).permit(
        :title,
        :badges
      )
    end
end

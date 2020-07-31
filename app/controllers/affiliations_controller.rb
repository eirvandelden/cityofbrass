# frozen_string_literal: false

class AffiliationsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_resident_by_id

  def index
    @affiliates = @resident.affiliates.page(params[:page])
  end

  def create
    @affiliate = Resident.find_by_id(params[:affiliate_id])

    respond_to do |format|
      if Affiliation.request(@resident, @affiliate)

        set_affiliations
        format.html { redirect_to resident_path(@affiliate.slug), notice: "Affiliation with #{@affiliate.name} requested" }
      else
        format.html { redirect_to resident_path(@affiliate.slug), notice: "Affiliation with #{@affiliate.name} cannot be requested" }
      end
    end

  end

  def create_campaign
    affiliate = Resident.find_by_id(params[:affiliate_id])

    respond_to do |format|
      if Affiliation.request(@resident, affiliate)
        set_campaign
        format.js   { flash.now[:notice] = "Affiliation with #{affiliate.name} requested" }
      else
        set_campaign
        format.js   { flash.now[:notice] = "Affiliation with #{affiliate.name} cannot be requested" }
      end
    end

  end

  def update
    @affiliate = Resident.find_by_id(params[:affiliate_id])
    unless @affiliate.nil?
      if params[:status] == 'accept'
        if Affiliation.accept(@resident, @affiliate)
          flash[:notice] = "Affiliation with #{@affiliate.name} updated"
        end
      elsif params[:status] == 'reject' || params[:status] == 'rescind'
        if Affiliation.reject(@resident, @affiliate)
          flash[:notice] = "Affiliation with #{@affiliate.name} #{params[:status]}ed"
        end
      elsif params[:status] == 'block'
        if Affiliation.block(@resident, @affiliate)
          flash[:notice] = "Affiliation with #{@affiliate.name} blocked"
        end
      else
        flash[:notice] = "Affiliation with #{@affiliate.name} cannot be updated"
      end
    end

    set_affiliations
    respond_to do |format|
      format.html { redirect_to affiliates_path }
      format.js
    end
  end

  def update_campaign
    @affiliate = Resident.find_by_id(params[:affiliate_id])
    unless @affiliate.nil?
      if params[:status] == 'accept'
        if Affiliation.accept(@resident, @affiliate)
          flash[:notice] = "Affiliation with #{@affiliate.name} updated"
        end
      elsif params[:status] == 'reject' || params[:status] == 'rescind'
        if Affiliation.reject(@resident, @affiliate)
          flash[:notice] = "Affiliation with #{@affiliate.name} #{params[:status]}ed"
        end
      elsif params[:status] == 'block'
        if Affiliation.block(@resident, @affiliate)
          flash[:notice] = "Affiliation with #{@affiliate.name} blocked"
        end
      else
        flash[:notice] = "Affiliation with #{@affiliate.name} cannot be updated"
      end
    end

    set_campaign
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resident_by_id
      @resident = current_user.resident
      if @resident.nil? || current_user.inactive?
        render template: 'errors/404', layout: 'layouts/application', status: 404
      end
    end

    def set_affiliations
      @top_5_pending_affiliations = @resident.top_5_pending_affiliations
      @top_5_requested_affiliations = @resident.top_5_requested_affiliations
      @top_10_affiliates = @resident.top_10_affiliates
    end

    def set_campaign
      @campaign = Campaignmanager::Campaign.includes([:player_residents]).find_by_id(params[:campaign_id])

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
    end

end

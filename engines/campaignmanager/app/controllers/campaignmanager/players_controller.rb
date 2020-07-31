# frozen_string_literal: false

require_dependency "campaignmanager/application_controller"

module Campaignmanager
  class PlayersController < ApplicationController

    before_action :set_parent_type
    before_action :set_parent_object
    before_action :check_parent_authorization
    before_action :set_campaign
    before_action :set_player, only: [:show, :edit, :update, :destroy]

    # GET /players
    def index
      @players = @campaign.players.includes([:affiliate_user]).page(params[:page])
    end

    # GET /players/new
    def new
      @player = @campaign.players.new
      @aff_list = @campaign.resident.affiliations.where("status = 'accepted'").collect {|a| [a.affiliate.name, a.id]}.sort
    end

    # POST /players
    def create
      @player = @campaign.players.new(player_params)
      @aff_list = @campaign.resident.affiliations.where("status = 'accepted'").collect {|a| [a.affiliate.name, a.id]}.sort

      respond_to do |format|
        if @player.save
          format.js
        else
          format.js
        end
      end
    end

    # DELETE /players/1
    def destroy
      @player.destroy
    end

    private

      def set_campaign
        @campaign = @parent_object
      end

      def set_player
        @player = @campaign.players.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def player_params
        params.require(:player).permit(:campaign_id, :affiliation_id)
      end
  end
end

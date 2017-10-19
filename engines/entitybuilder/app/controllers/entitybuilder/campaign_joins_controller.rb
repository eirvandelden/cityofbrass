require_dependency "entitybuilder/application_controller"

module Entitybuilder
  class CampaignJoinsController < ApplicationController

    before_action :set_campaign_join
    before_action :check_authorization

    # DELETE /campaign_joins/1
    def destroy
      @campaign_join.destroy

      respond_to do |format|
        format.js
      end
    end

    private

      def set_campaign_join
        @campaign_join = Entitybuilder::CampaignJoin.find(params[:id])
        @campaign = @campaign_join.campaign
        @character = @campaign_join.entity
      end

      def check_authorization
        unless current_user == @campaign.resident.user
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      # Only allow a trusted parameter "white list" through.
      def campaign_join_params
        params.require(:caster_level).permit(
            :entity_id,
            :campaign_id
          )
      end

  end
end

# frozen_string_literal: false

require_dependency "report/application_controller"

module Report
  class CampaignmanagerSnapshotsController < ApplicationController

    # GET /resident_snapshots
    def index
      @paid_counts = {}
      @paid_counts[:campaigns] = Campaignmanager::Campaign.joins(:user).where("users.status in (?)", ['active']).count
      @paid_counts[:pages] = Campaignmanager::Page.joins(:user).where("users.status in (?)", ['active']).count
      @paid_counts[:players] = Campaignmanager::Player.joins(:affiliate_user).where("users.status in (?)", ['active']).count

      @paid_page_counts = Campaignmanager::Page.find_by_sql("
        SELECT type, count(*) as num
        FROM
          campaignmanager_pages
          INNER JOIN campaignmanager_campaigns on campaignmanager_campaigns.id = campaign_id
          INNER JOIN residents on residents.id = resident_id
          INNER JOIN users on users.id = user_id AND status in ('active')
        GROUP BY type
        ORDER BY type"
      )

      @free_counts = {}
      @free_counts[:campaigns] = Campaignmanager::Campaign.joins(:user).where("users.status in (?)", ['free']).count
      @free_counts[:pages] = Campaignmanager::Page.joins(:user).where("users.status in (?)", ['free']).count
      @free_counts[:players] = Campaignmanager::Player.joins(:affiliate_user).where("users.status in (?)", ['free']).count

      @free_page_counts = Campaignmanager::Page.find_by_sql("
        SELECT type, count(*) as num
        FROM
          campaignmanager_pages
          INNER JOIN campaignmanager_campaigns on campaignmanager_campaigns.id = campaign_id
          INNER JOIN residents on residents.id = resident_id
          INNER JOIN users on users.id = user_id AND status in ('free')
        GROUP BY type
        ORDER BY type"
      )
    end

    private
      # Only allow a trusted parameter "white list" through.
      def campaignmanager_snapshot_params
        params[:campaignmanager_snapshot]
      end
  end
end

require_dependency "report/application_controller"

module Report
  class WorldbuilderSnapshotsController < ApplicationController

    # GET /resident_snapshots
    def index

      @paid_counts = {}
      @paid_counts[:districts] = Worldbuilder::District.joins(:user).where("users.status in (?)", ['active']).count
      @paid_counts[:pages] = Worldbuilder::Page.joins(:user).where("users.status in (?)", ['active']).count
      @paid_counts[:contributors] = Worldbuilder::Contributor.joins(:affiliate_user).where("users.status in (?)", ['active']).count

      @free_counts = {}
      @free_counts[:districts] = Worldbuilder::District.joins(:user).where("users.status in (?)", ['free']).count
      @free_counts[:pages] = Worldbuilder::Page.joins(:user).where("users.status in (?)", ['free']).count
      @free_counts[:contributors] = Worldbuilder::Contributor.joins(:affiliate_user).where("users.status in (?)", ['free']).count

    end

    private
      # Only allow a trusted parameter "white list" through.
      def worldbuilder_snapshot_params
        params[:worldbuilder_snapshot]
      end
  end
end

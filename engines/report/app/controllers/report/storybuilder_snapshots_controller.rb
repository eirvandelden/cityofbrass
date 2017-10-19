require_dependency "report/application_controller"

module Report
  class StorybuilderSnapshotsController < ApplicationController

    # GET /resident_snapshots
    def index
      #@resident_snapshots = ResidentSnapshot

      @paid_counts = {}
      @paid_counts[:adventures] = Storybuilder::ResidentAdventure.joins(:user).where("users.status in (?)", ['active']).count
      @paid_counts[:pages] = Storybuilder::Page.joins(:user).where("users.status in (?)", ['active']).count

      @free_counts = {}
      @free_counts[:adventures] = Storybuilder::ResidentAdventure.joins(:user).where("users.status in (?)", ['free']).count
      @free_counts[:pages] = Storybuilder::Page.joins(:user).where("users.status in (?)", ['free']).count

    end

    private
      # Only allow a trusted parameter "white list" through.
      def storybuilder_snapshot_params
        params[:storybuilder_snapshot]
      end
  end
end

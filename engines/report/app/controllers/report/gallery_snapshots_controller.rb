# frozen_string_literal: false

require_dependency "report/application_controller"

module Report
  class GallerySnapshotsController < ApplicationController

    # GET /gallery_snapshots
    def index
      #@gallery_snapshots = GallerySnapshot.all
    end

    private
      # Only allow a trusted parameter "white list" through.
      def gallery_snapshot_params
        params[:gallery_snapshot]
      end
  end
end

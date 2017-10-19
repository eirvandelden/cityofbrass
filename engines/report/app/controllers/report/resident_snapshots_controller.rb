require_dependency "report/application_controller"

module Report
  class ResidentSnapshotsController < ApplicationController

    # GET /resident_snapshots
    def index
      #@resident_snapshots = ResidentSnapshot
    end

    private
      # Only allow a trusted parameter "white list" through.
      def resident_snapshot_params
        params[:resident_snapshot]
      end
  end
end

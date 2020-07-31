require_dependency "report/application_controller"

module Report
  class DashboardsController < ApplicationController

    # GET /dashboards
    def index
      #@dashboards = Dashboard.all
    end
    private
      # Only allow a trusted parameter "white list" through.
      def dashboard_params
        params[:dashboard]
      end
  end
end

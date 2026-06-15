module Importer
  class ApplicationController < ::ApplicationController
    helper Importer::ImportsHelper

    before_action :authenticate_user!
    before_action :check_user_status
    before_action :require_resident

    private

    def require_resident
      redirect_to main_app.new_resident_path if current_user.resident.blank?
    end
  end
end

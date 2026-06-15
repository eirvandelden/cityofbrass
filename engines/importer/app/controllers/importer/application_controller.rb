module Importer
  class ApplicationController < ::ApplicationController
    helper Importer::ImportsHelper

    before_action :authenticate_user!
    before_action :check_user_status
  end
end

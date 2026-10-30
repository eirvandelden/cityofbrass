# Base controller for Mission Control Jobs at /jobs: admins only.
class MissionControlController < ActionController::Base
  include Authentication

  before_action :authenticate_admin!
end

# frozen_string_literal: false

class Activeplay::ApplicationController < ApplicationController
  before_action :authenticate_user!
  before_action :check_user_status
end

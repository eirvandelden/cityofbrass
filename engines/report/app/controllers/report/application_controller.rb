# frozen_string_literal: false

class Report::ApplicationController < ApplicationController
  before_action :authenticate_admin!
end

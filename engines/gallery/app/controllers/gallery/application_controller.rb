# frozen_string_literal: false

class Gallery::ApplicationController < ApplicationController
  before_action :authenticate_user!, except: [:swoosh]
  before_action :check_user_status,  except: [:swoosh]
end

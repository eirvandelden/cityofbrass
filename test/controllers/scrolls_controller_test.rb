# frozen_string_literal: false

require 'test_helper'

class ScrollsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test "should show home" do
    get :home
    assert_response :success
  end

  test "should show terms of service" do
    get :terms_of_service
    assert_response :success
  end

  test "should show haster" do
    get :hastur
    assert_response :success
  end
end

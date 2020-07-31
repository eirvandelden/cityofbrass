# frozen_string_literal: false

require 'test_helper'

module Entitybuilder
  class CampaignJoinsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Entitybuilder::Engine.routes
      @user = users(:dan)
      @gm = users(:lucas)

      @campaign_join = entitybuilder_campaign_joins(:one)
    end

    test "should not destroy campaign_join" do
      sign_in @user
      assert_difference('CampaignJoin.count', 0) do
        delete :destroy, format: :js, params: { id: @campaign_join }
      end
      assert_response 403
    end

    test "should destroy campaign_join" do
      sign_in @gm
      assert_difference('CampaignJoin.count', -1) do
        delete :destroy, format: :js, params: { id: @campaign_join }
      end
      assert_response 200
    end

  end
end

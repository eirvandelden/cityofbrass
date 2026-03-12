require "test_helper"

class CampaignmanagerTest < ActiveSupport::TestCase
  test "loads the engine" do
    assert_kind_of Module, Campaignmanager
    assert_operator Campaignmanager::Engine, :<, Rails::Engine
  end
end

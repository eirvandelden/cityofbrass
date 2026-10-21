require "test_helper"

class ActiveplayVirtualTableTokenTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @secret_before = ENV["ACTIVEPLAY_SECRET"]
    ENV["ACTIVEPLAY_SECRET"] = "virtual-table-test-secret"
    @game_master = users(:dan)
    @campaign = campaignmanager_campaigns(:resident_one)
    @virtual_table = Activeplay::VirtualTable.create!(campaign: @campaign)
  end

  teardown do
    ENV["ACTIVEPLAY_SECRET"] = @secret_before
  end

  test "game master receives an HS256 token signed with the activeplay secret" do
    sign_in @game_master

    get "/ap/virtual_tables/#{@virtual_table.id}/new_token", xhr: true

    assert_response :success
    payload, header = JWT.decode(token_in_response, "virtual-table-test-secret", true, algorithm: "HS256")

    assert_equal "HS256", header["alg"]
    assert_equal "GM", payload["name"]
    assert_equal @game_master.resident.id, payload["residentId"]
    assert_equal @campaign.id, payload["campaignId"]
    assert_operator payload["exp"], :>, Time.now.to_i
  end

  private

  def token_in_response
    response.body[/token = '([^']+)'/, 1]
  end
end

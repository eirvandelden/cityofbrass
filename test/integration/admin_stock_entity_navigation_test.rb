require "test_helper"

class AdminStockEntityNavigationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:dan)
    @admin = admins(:dan)
    @creature = entitybuilder_entities(:stock_creature_one)
  end

  test "nested entity pages keep admin stock links" do
    sign_in @user
    sign_in @admin

    get "/eb/admin/stock/creatures/#{@creature.id}/descriptors"

    assert_response :success
    assert_select "a[href='/eb/admin/stock/creatures/#{@creature.id}/descriptors/new']"
  end
end

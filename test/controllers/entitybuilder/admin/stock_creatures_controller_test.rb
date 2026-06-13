require "test_helper"

module Entitybuilder
  module Admin
    class StockCreaturesControllerTest < ActionController::TestCase
      include Devise::Test::ControllerHelpers

      setup do
        @routes = Entitybuilder::Engine.routes
        @user = users(:dan)
        @user2 = users(:lucas)
        @admin = admins(:dan)

        @creature = entitybuilder_entities(:stock_creature_one)
      end

      test "should not get index" do
        get :index
        assert_response 302
      end

      test "should not get index for user" do
        sign_in @user
        get :index
        assert_response 403
      end

      test "should get index" do
        sign_in @user
        sign_in @admin
        get :index
        assert_response :success
        assert_not_nil assigns(:entities)
        assert_select "a[href='#{new_admin_stock_creature_path}']"
        assert_select "a[href='#{edit_admin_stock_creature_path(@creature)}']"
      end

      test "should not get new" do
        sign_in @user
        get :new
        assert_response 403
      end

      test "should get new" do
        sign_in @user
        sign_in @admin
        get :new
        assert_response :success
      end

      test "should not create creature login" do
        assert_difference("Entity.count", 0) do
          post :create, params: { stock_creature: { name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
        end
        assert_response 302
      end

      test "should not create creature" do
        sign_in @user
        assert_difference("Entity.count", 0) do
          post :create, params: { stock_creature: { name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
        end
        assert_response 403
      end

      test "should create creature" do
        sign_in @user
        sign_in @admin
        assert_difference("Entity.count") do
          post :create, params: { stock_creature: { name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
        end
        assert_redirected_to edit_admin_stock_creature_path(assigns(:entity))
      end

      test "should not show creature" do
        get :show, params: { id: @creature }
        assert_response 302
      end

      test "should show creature" do
        sign_in @user
        get :show, params: { id: @creature }
        assert_response :success
      end

      test "should not get edit" do
        sign_in @user
        get :edit, params: { id: @creature }
        assert_response 403
      end

      test "should get edit" do
        sign_in @user
        sign_in @admin
        get :edit, params: { id: @creature }
        assert_response :success
        assert_select "form[action='#{admin_stock_creature_path(@creature)}']"
      end

      test "should route admin nested resources to existing controllers" do
        assert_recognizes(
          {
            controller: "entitybuilder/descriptors",
            action: "index",
            stock_creature_id: @creature.id.to_s
          },
          "/admin/stock/creatures/#{@creature.id}/descriptors",
        )
        assert_equal "/eb/admin/stock/creatures/#{@creature.id}/descriptors", admin_stock_creature_descriptors_path(@creature)
      end

      test "should not update creature" do
        sign_in @user
        patch :update, params: { id: @creature, stock_creature: { name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
        assert_response 403
      end

      test "should update creature" do
        sign_in @user
        sign_in @admin
        patch :update, params: { id: @creature, stock_creature: { name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
        assert_redirected_to edit_admin_stock_creature_path(assigns(:entity))
      end

      test "should not destroy creature" do
        sign_in @user
        assert_difference("Entity.count", 0) do
          delete :destroy, params: { id: @creature, stock_creature: { name: @creature.name } }
        end
        assert_response 403
      end

      test "should destroy creature" do
        sign_in @user
        sign_in @admin
        assert_difference("Entity.count", -1) do
          delete :destroy, params: { id: @creature, stock_creature: { name: @creature.name } }
        end
        assert_redirected_to admin_stock_creatures_path
      end
    end
  end
end

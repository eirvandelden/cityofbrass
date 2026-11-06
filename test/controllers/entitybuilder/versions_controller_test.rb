require "test_helper"

module Entitybuilder
  class VersionsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Entitybuilder::Engine.routes
      @creature = entitybuilder_entities(:resident_creature_one)
    end

    test "non-owner gets 403" do
      sign_in users(:lucas)

      assert_no_difference("Entity.count") do
        post :create, params: { resident_creature_id: @creature.id, version: { version_label: "Level 10" } }
      end
      assert_response 403
    end

    test "blank label renders the form with an error" do
      sign_in users(:dan)

      assert_no_difference("Entity.count") do
        post :create, params: { resident_creature_id: @creature.id, version: { version_label: "" } }
      end
      assert_response :unprocessable_content
      assert_select "form"
      assert_select ".error", text: /blank/i
    end

    test "a missing label param renders the form with an error" do
      sign_in users(:dan)
      built = entitybuilder_entities(:four_e_creature_built)

      assert_no_difference("Entity.count") do
        post :create, params: { resident_creature_id: built.id, version: { monster_level: "10" } }
      end
      assert_response :unprocessable_content
      assert_select ".error", text: /blank/i
    end

    test "a refused level renders the form with the typed level" do
      sign_in users(:dan)
      built = entitybuilder_entities(:four_e_creature_built)

      assert_no_difference("Entity.count") do
        post :create, params: { resident_creature_id: built.id,
                                version: { version_label: "Epic", monster_level: "41" } }
      end
      assert_response :unprocessable_content
      assert_select "input[name=?][value='41']", "version[monster_level]"
      assert_select ".error"
    end

    test "blank label keeps the typed level" do
      sign_in users(:dan)
      built = entitybuilder_entities(:four_e_creature_built)

      post :create, params: { resident_creature_id: built.id, version: { version_label: "", monster_level: "10" } }

      assert_response :unprocessable_content
      assert_select "input[name=?][value='10']", "version[monster_level]"
    end

    test "creates a version and redirects to its edit page" do
      sign_in users(:dan)

      assert_difference("Entity.count", 1) do
        post :create, params: { resident_creature_id: @creature.id, version: { version_label: "Level 10" } }
      end
      version = Entity.find_by!(parent_id: @creature.id)

      assert_redirected_to "/eb/resident/creatures/#{version.id}/edit"
    end

    test "new renders the form for the owner" do
      sign_in users(:dan)

      get :new, params: { resident_creature_id: @creature.id }

      assert_response :success
    end

    test "new shows a level field only for a built monster" do
      sign_in users(:dan)

      get :new, params: { resident_creature_id: entitybuilder_entities(:four_e_creature_built).id }

      assert_select "input[name=?]", "version[monster_level]"

      get :new, params: { resident_creature_id: @creature.id }

      assert_select "input[name=?]", "version[monster_level]", count: 0
    end
  end
end

require "test_helper"

module Entitybuilder
  class MonsterBuildsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Entitybuilder::Engine.routes
      @controller = Entitybuilder::MonsterBuildsController.new
      @monster = entitybuilder_entities(:four_e_creature_built)
    end

    test "non-owner gets 403" do
      sign_in users(:lucas)

      get :edit, params: { resident_creature_id: @monster.id }

      assert_response 403

      patch :update, params: { resident_creature_id: @monster.id, resident_creature: { monster_level: 9 } }

      assert_response 403
      assert_equal 5, @monster.reload.monster_level
    end

    test "non-4e creature gets 404" do
      sign_in users(:dan)
      pathfinder = entitybuilder_entities(:resident_creature_pf2e)

      get :edit, params: { resident_creature_id: pathfinder.id }

      assert_response 404
    end

    test "invalid inputs render the form with errors" do
      sign_in users(:dan)

      patch :update, params: { resident_creature_id: @monster.id, resident_creature: { monster_level: 0 } }

      assert_response :unprocessable_content
      assert_select "form"
      assert_select ".error"
      assert_equal 5, @monster.reload.monster_level
    end

    test "level above 40 renders the form with errors" do
      sign_in users(:dan)

      patch :update, params: { resident_creature_id: @monster.id, resident_creature: { monster_level: 41 } }

      assert_response :unprocessable_content
      assert_select ".error"
      assert_equal 5, @monster.reload.monster_level
    end

    test "a submitted value is stored and marked" do
      sign_in users(:dan)

      patch :update,
params: { resident_creature_id: @monster.id, resident_creature: { monster_values: { fortitude: "25" } } }

      assert_redirected_to "/eb/resident/creatures/#{@monster.id}/monster_build/edit"
      assert_equal 25, @monster.defenses.find_by(name: "Fortitude").bonus

      get :edit, params: { resident_creature_id: @monster.id }

      assert_select "tr", text: /Fortitude.*needs manual revision/im
    end
  end

  class MonsterOverridesControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Entitybuilder::Engine.routes
      @controller = Entitybuilder::MonsterOverridesController.new
      @monster = entitybuilder_entities(:four_e_creature_built)
    end

    test "reset of an unknown key gets 404" do
      sign_in users(:dan)

      delete :destroy, params: { resident_creature_id: @monster.id, id: "bogus" }

      assert_response 404
    end

    test "reset on an unbuilt monster gets 404" do
      sign_in users(:dan)

      unbuilt = entitybuilder_entities(:four_e_creature_unbuilt)

      delete :destroy, params: { resident_creature_id: unbuilt.id, id: "armor_class" }

      assert_response 404
    end
  end
end

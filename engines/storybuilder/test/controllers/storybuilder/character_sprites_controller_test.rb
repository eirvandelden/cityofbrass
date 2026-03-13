require 'test_helper'

module Storybuilder
  class CharacterNotablesControllerTest < ActionController::TestCase
    setup do
      @character_notable = character_notables(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:character_notables)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create character_notable" do
      assert_difference('CharacterNotable.count') do
        post :create, character_notable: { character_id: @character_notable.character_id, name: @character_notable.name, sort_order: @character_notable.sort_order, notableable_id: @character_notable.notableable_id, notableable_type: @character_notable.notableable_type }
      end

      assert_redirected_to character_notable_path(assigns(:character_notable))
    end

    test "should show character_notable" do
      get :show, id: @character_notable
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @character_notable
      assert_response :success
    end

    test "should update character_notable" do
      patch :update, id: @character_notable, character_notable: { character_id: @character_notable.character_id, name: @character_notable.name, sort_order: @character_notable.sort_order, notableable_id: @character_notable.notableable_id, notableable_type: @character_notable.notableable_type }
      assert_redirected_to character_notable_path(assigns(:character_notable))
    end

    test "should destroy character_notable" do
      assert_difference('CharacterNotable.count', -1) do
        delete :destroy, id: @character_notable
      end

      assert_redirected_to character_notables_path
    end
  end
end

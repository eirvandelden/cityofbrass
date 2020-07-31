# frozen_string_literal: false

require 'test_helper'

module Entitybuilder
  class CharactersControllerTest < ActionController::TestCase
    setup do
      @character = entitybuilder_characters(:one)
    end

    test "should get index" do
      get :index, use_route: :entitybuilder
      assert_response :success
      assert_not_nil assigns(:characters)
    end

    test "should show character" do
      get :show, use_route: :entitybuilder, id: @character
      assert_response :success
    end

  end
end

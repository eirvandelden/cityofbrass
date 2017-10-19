require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @dan = admins(:dan)
    @user1 = users(:dan)
    @user2 = users(:courtney)
  end

  test "should get index.html" do
    sign_in @user1
    sign_in @dan
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get index.js" do
    sign_in @dan
    get :index, xhr: true, format: :js
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get edit" do
    sign_in @dan
    get :edit, params: { id: @user2 }
  end

  test "should update.js" do
    sign_in @dan
    patch :update, format: :js, params: { id: @user2, user: { email: @user2.email, status: @user2.status } }
    assert_response :success
    assert_equal "#{@user2.email} has been updated.", flash[:notice]
  end

end

require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @dan = users(:dan)
    @razune = residents(:razune)
    @message = messages(:message1)
  end

  test "should get inbox" do
    sign_in @dan
    get :inbox, params: { resident_id: @razune.slug }
    assert_response :success
    assert_not_nil assigns(:messages)
  end

  test "should get sent" do
    sign_in @dan
    get :sent, params: { resident_id: @razune.slug }
    assert_response :success
    assert_not_nil assigns(:messages)
  end

  test "should get new" do
    sign_in @dan
    get :new, params: { resident_id: @razune.id }
    assert_response :success
  end

  test "should create message" do
    sign_in @dan
    assert_difference('Message.count') do
      post :create, params: { resident_id: @razune.slug, message: { subject: "test", recipient_id: residents(:razune).id, sender_id: residents(:tuandn).id, id: "c7276bf3-21bd-4e11-877e-244339208499" } }
    end
    assert_response 302
    assert_equal "Message has been sent.", flash[:notice]
    assert_redirected_to inbox_path
  end

  test "should not show message" do
    get :show, params: { resident_id: @razune.slug, id: @message.id }
    assert_response 302
    assert_redirected_to new_user_session_path
  end

  test "should show message" do
    sign_in @dan
    get :show, params: { resident_id: @razune.slug, id: @message.id }
    assert_response :success
    assert_not_nil assigns(:message)
  end

  test "should get edit" do
    sign_in @dan
    get :edit, params: { resident_id: @razune.slug, id: @message }
    assert_response :success
  end

  test "should update message" do
    sign_in @dan
    patch :update, params: { resident_id: @razune.slug, id: @message, message: { body: "<p>test</p>" } }
    assert_response 302
    assert_equal "Message has been sent.", flash[:notice]
    assert_redirected_to inbox_path
  end

  test "deleting a message you sent takes it out of your sent list" do
    sign_in @dan

    delete :destroy, params: { resident_id: @razune.slug, id: @message }

    assert_redirected_to inbox_path
    assert_not_includes @razune.messages_sent.reload, @message
  end
end

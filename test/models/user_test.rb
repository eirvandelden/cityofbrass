require 'test_helper'
require Rails.root.join("test/support/authenticatable_tests")

class UserTest < ActiveSupport::TestCase
  include AuthenticatableTests

  test "should have the necessary required validators" do
    user = users(:dan)
    user.status =""
    assert_not user.valid?
    assert_equal [:status], user.errors.attribute_names
  end

  test "update_account requires current password for an email change" do
    assert_not account.update_account(email: "changed@example.com")
    assert_includes account.errors.attribute_names, :current_password
    assert account.update_account(email: "changed@example.com", current_password: "password")
  end

  test "update_account changes locale without current password" do
    assert account.update_account(locale: "nl")
    assert_equal "nl", account.reload.locale
  end

  private
    def account = users(:dan)
    def account_class = User
end

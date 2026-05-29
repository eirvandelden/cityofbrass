require "application_system_test_case"

class SignInTest < ApplicationSystemTestCase
  test "user signs in" do
    sign_in_as users(:dan), scope: :user

    assert_text "Signed in successfully."
    assert_text "Account"
    assert_text "City of Brass"
  end

  test "admin signs in" do
    sign_in_as admins(:dan), scope: :admin

    assert_text "Signed in successfully."
    assert_text "User Admin"
    assert_text "Billing Events"
  end
end

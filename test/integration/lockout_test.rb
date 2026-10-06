require "test_helper"

class LockoutTest < ActionDispatch::IntegrationTest
  test "twentieth failure locks the account" do
    20.times { attempt("wrong") }
    attempt("password")

    assert_response :unprocessable_entity
    assert_select "label.error", text: "Your account is locked."
    assert_not_nil users(:dan).reload.locked_at
  end

  test "lock expires after one hour" do
    20.times { attempt("wrong") }

    travel 61.minutes do
      attempt("password")

      assert_redirected_to root_url
      assert_nil users(:dan).reload.locked_at
    end
  end

  test "lock still holds within the hour" do
    20.times { attempt("wrong") }

    travel 59.minutes do
      attempt("password")

      assert_response :unprocessable_entity
    end
  end

  test "successful sign in clears failed attempts" do
    3.times { attempt("wrong") }

    assert_equal 3, users(:dan).reload.failed_attempts
    attempt("password")

    assert_equal 0, users(:dan).reload.failed_attempts
  end

  private
    def attempt(password)
      post user_session_path, params: { user: { email: users(:dan).email, password: password } }
    end
end

require "test_helper"

class PasswordResetsTest < ActionDispatch::IntegrationTest
  JOB_CLASSES = [ ActiveJob::Base, ActionMailer::MailDeliveryJob ].freeze

  setup do
    @queue_adapters = JOB_CLASSES.index_with(&:queue_adapter)
    inline = ActiveJob::QueueAdapters::TestAdapter.new.tap { |adapter| adapter.perform_enqueued_jobs = true }
    JOB_CLASSES.each { |job_class| job_class.queue_adapter = inline }
    @mailer_defaults = PasswordsMailer.default_params
    PasswordsMailer.default_params = @mailer_defaults.merge(from: "support@example.com")
  end

  teardown do
    @queue_adapters.each { |job_class, adapter| job_class.queue_adapter = adapter }
    PasswordsMailer.default_params = @mailer_defaults
  end

  test "reset changes the password and unlocks the account" do
    user = users(:dan)
    user.update_columns(failed_attempts: 20, locked_at: Time.current)

    patch user_password_path(user.password_reset_token),
          params: { user: { password: "new-password", password_confirmation: "new-password" } }

    assert_redirected_to root_path
    assert_nil user.reload.locked_at
    assert user.authenticate("new-password")
  end

  test "reset email link works within six hours" do
    post user_passwords_path, params: { user: { email: users(:dan).email } }
    link = ActionMailer::Base.deliveries.last.body.to_s[%r{http://[^"\s]+/users/passwords/[^"\s]+/edit}]

    travel 5.hours do
      get link

      assert_response :success
    end
  end

  test "reset link older than six hours is refused" do
    token = users(:dan).password_reset_token

    travel 7.hours do
      get edit_user_password_path(token)

      assert_redirected_to new_user_password_path
    end
  end

  test "unknown email gets the same response" do
    post user_passwords_path, params: { user: { email: "nobody@example.com" } }
    unknown = [ response.status, response.location, flash[:notice] ]
    post user_passwords_path, params: { user: { email: users(:dan).email } }

    assert_equal unknown, [ response.status, response.location, flash[:notice] ]
  end

  test "admin reset mail links to the admin edit path" do
    post admin_passwords_path, params: { admin: { email: admins(:dan).email } }

    assert_match %r{/admins/passwords/[^"\s]+/edit}, ActionMailer::Base.deliveries.last.body.to_s
  end

  test "too short new password re-renders with errors and keeps the token" do
    token = users(:dan).password_reset_token
    patch user_password_path(token), params: { user: { password: "short", password_confirmation: "short" } }

    assert_response :unprocessable_entity
    assert_select "form[action=?]", user_password_path(token)
  end

  test "mismatched confirmation re-renders with errors" do
    token = users(:dan).password_reset_token
    patch user_password_path(token),
          params: { user: { password: "long-enough-1", password_confirmation: "other-1234" } }

    assert_response :unprocessable_entity
  end

  test "missing confirmation re-renders with errors and keeps the old password" do
    user = users(:dan)
    patch user_password_path(user.password_reset_token), params: { user: { password: "long-enough-1" } }

    assert_response :unprocessable_entity
    assert user.reload.authenticate("password")
  end

  test "a reset request without password fields is a bad request, not an error" do
    patch user_password_path(users(:dan).password_reset_token), params: { user: "not-a-hash" }

    assert_response :bad_request
  end

  test "a reset request with a malformed account param is a bad request, not an error" do
    post user_passwords_path, params: { user: "not-a-hash" }

    assert_response :bad_request
  end
end

# Shared examples for models that include Authenticatable. Expects `account` and `account_class`.
require "minitest/mock"

module AuthenticatableTests
  extend ActiveSupport::Concern

  included do
    test "authenticate_by_credentials returns the account for the right password" do
      assert_equal account, account_class.authenticate_by_credentials(email: account.email, password: "password")
    end

    test "authenticate_by_credentials returns nil for a wrong password" do
      assert_nil account_class.authenticate_by_credentials(email: account.email, password: "wrong")
    end

    test "authenticate_by_credentials returns nil for an unknown email" do
      assert_nil account_class.authenticate_by_credentials(email: "nobody@example.com", password: "password")
    end

    test "authenticate_by_credentials refuses a locked account with the right password" do
      account.update_columns(failed_attempts: 20, locked_at: Time.current)

      assert_raises(Authenticatable::Locked) do
        account_class.authenticate_by_credentials(email: account.email, password: "password")
      end
    end

    test "register_failed_attempt locks at twenty" do
      19.times { account.register_failed_attempt }

      assert_not account.reload.locked?
      account.register_failed_attempt

      assert_predicate account.reload, :locked?
    end

    test "register_failed_attempt counts attempts made through stale copies" do
      stale_copies = Array.new(Authenticatable::MAXIMUM_ATTEMPTS) { account_class.find(account.id) }
      stale_copies.each(&:register_failed_attempt)

      assert_equal Authenticatable::MAXIMUM_ATTEMPTS, account.reload.failed_attempts
      assert_predicate account, :locked?
    end

    test "authenticate_by_credentials hashes a password for an unknown email" do
      hashed = false
      BCrypt::Password.stub(:create, ->(*) { hashed = true }) do
        account_class.authenticate_by_credentials(email: "nobody@example.com", password: "password")
      end

      assert hashed, "an unknown email must cost a password hash, like a known one"
    end

    test "changing the password ends the account's other sessions" do
      2.times { account.start_session(ip_address: "203.0.113.5", user_agent: "Agent") }

      account.reset_password(password: "brand-new-pass", password_confirmation: "brand-new-pass")

      assert_empty account.sessions.reload
    end

    test "changing the password keeps the session making the change" do
      current = account.start_session(ip_address: "203.0.113.5", user_agent: "Agent")
      other = account.start_session(ip_address: "203.0.113.6", user_agent: "Agent")
      Current.public_send("#{account_class.name.underscore}_session=", current)

      account.update!(password: "brand-new-pass", password_confirmation: "brand-new-pass")

      assert_equal [ current ], account.sessions.reload.to_a
      assert_not Session.exists?(other.id)
    end

    test "reset_password ends every session, including the current one" do
      current = account.start_session(ip_address: "203.0.113.5", user_agent: "Agent")
      Current.public_send("#{account_class.name.underscore}_session=", current)

      account.reset_password(password: "brand-new-pass", password_confirmation: "brand-new-pass")

      assert_empty account.sessions.reload
    end

    test "reset_password changes nothing when ending the sessions fails" do
      kept = account.start_session(ip_address: "203.0.113.5", user_agent: "Agent")

      account.stub(:unlock, -> { raise ActiveRecord::ActiveRecordError, "boom" }) do
        assert_raises(ActiveRecord::ActiveRecordError) do
          account.reset_password(password: "brand-new-pass", password_confirmation: "brand-new-pass")
        end
      end

      assert account.reload.authenticate("password")
      assert Session.exists?(kept.id)
    end

    test "saving without a password change keeps every session" do
      account.start_session(ip_address: "203.0.113.5", user_agent: "Agent")

      account.update!(email: "renamed-#{account.email}")

      assert_equal 1, account.sessions.reload.count
    end

    test "expired lock is cleared before authenticating" do
      account.update_columns(failed_attempts: 20, locked_at: 2.hours.ago)

      assert account.authenticate_unless_locked("password")
      assert_not account.reload.locked?
    end

    test "start_session creates a session and records tracking" do
      session_record = account.start_session(ip_address: "203.0.113.5", user_agent: "Agent")

      assert_equal account, session_record.authenticatable
      assert_equal 1, account.reload.sign_in_count
      assert_equal "203.0.113.5", account.current_sign_in_ip
    end

    test "start_session resets failed attempts" do
      account.update_columns(failed_attempts: 5)
      account.start_session(ip_address: "203.0.113.5", user_agent: "Agent")

      assert_equal 0, account.reload.failed_attempts
    end

    test "reset_password updates and unlocks" do
      account.update_columns(failed_attempts: 20, locked_at: Time.current)

      assert account.reset_password(password: "brand-new-pass", password_confirmation: "brand-new-pass")
      assert account.reload.authenticate("brand-new-pass")
      assert_not account.locked?
    end

    test "password_reset_token expires after six hours" do
      token = account.password_reset_token

      assert_equal account, account_class.find_by_password_reset_token(token)
      travel(7.hours) { assert_nil account_class.find_by_password_reset_token(token) }
    end

    test "password shorter than eight is invalid" do
      account.password = "short"

      assert_not account.valid?
      assert_includes account.errors.attribute_names, :password
    end

    test "password over 72 bytes is invalid" do
      account.password = "a" * 73

      assert_not account.valid?
    end

    test "normalizes email" do
      account.email = "  MiXed@Example.COM "

      assert_equal "mixed@example.com", account.email
    end
  end
end

require 'test_helper'
require Rails.root.join("test/support/authenticatable_tests")

class AdminTest < ActiveSupport::TestCase
  include AuthenticatableTests

  private
    def account = admins(:dan)
    def account_class = Admin
end

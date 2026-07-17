require "test_helper"
require "bundler/audit/scanner"

class BundlerAuditConfigTest < ActiveSupport::TestCase
  test "loads project advisory exceptions by default" do
    scanner = Bundler::Audit::Scanner.new(Rails.root)

    assert_includes scanner.config.ignore, "CVE-THAT-DOES-NOT-APPLY"
  end
end

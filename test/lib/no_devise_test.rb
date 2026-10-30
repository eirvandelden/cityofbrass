require "test_helper"

class NoDeviseTest < ActiveSupport::TestCase
  LOCK_FILES = [ "Gemfile.lock", "engines/importer/Gemfile.lock" ].freeze

  test "devise is gone" do
    assert_not defined?(Devise), "Devise must not be loaded"
    LOCK_FILES.each do |lock_file|
      assert_no_match(/^\s+devise/, Rails.root.join(lock_file).read, "#{lock_file} must not lock devise")
    end
    assert_no_match(/devise_for/, Rails.root.join("config/routes.rb").read)
  end

  test "no test includes devise helpers" do
    test_files = Rails.root.glob("{test,engines/*/test}/**/*_test.rb") - [ Pathname(__FILE__) ]
    offenders = test_files.select { |file| file.read.include?("Devise::") }

    assert_empty offenders.map { |file| file.relative_path_from(Rails.root).to_s }
  end
end

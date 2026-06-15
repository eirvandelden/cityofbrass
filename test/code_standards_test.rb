require "test_helper"

class CodeStandardsTest < ActiveSupport::TestCase
  test "ruby source files do not disable rubocop" do
    offenders = ruby_source_files.filter_map do |file|
      "#{file.relative_path_from(Rails.root)} contains RuboCop disable comments" if file.read.include?(disable_comment)
    end

    assert_empty offenders
  end

  private

  def ruby_source_files
    Rails.root.glob("{app,config,db,engines,lib,test}/**/*.{rb,rake}")
  end

  def disable_comment
    "rubocop" + ":disable"
  end
end

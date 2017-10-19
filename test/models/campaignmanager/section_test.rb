require 'test_helper'

module Campaignmanager
  class SectionTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      section = Section.new(section_type: "paragraph")
      assert_not section.valid?
      assert_equal [:sectionable_type, :section_style], section.errors.keys
    end

  end
end

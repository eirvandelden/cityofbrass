# frozen_string_literal: false

require 'test_helper'

module Storybuilder
  class SectionTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      section = Section.new(section_type: "paragraph")
      assert_not section.valid?
      assert_equal [:sectionable_type, :section_style], section.errors.keys
    end

  end
end

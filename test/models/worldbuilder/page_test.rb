# frozen_string_literal: false

require 'test_helper'

module Worldbuilder
  class PageTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      page = Page.new(name: "PageName")
      assert_not page.valid?
      assert_equal [:district_id], page.errors.keys
    end

  end
end

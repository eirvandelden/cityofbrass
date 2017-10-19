require 'test_helper'

module Worldbuilder
  class DistrictTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      district = District.new(name: "DistrictTest")
      assert_not district.valid?
      assert_equal [:resident_id, :privacy], district.errors.keys
    end

  end
end

require 'test_helper'

module Worldbuilder
  class ContributorTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      contributor = Contributor.new
      assert_not contributor.valid?
      assert_equal [:district, :affiliation, :district_id, :affiliation_id], contributor.errors.attribute_names
    end

  end
end

# frozen_string_literal: false

require 'test_helper'

module Worldbuilder
  class ContributorTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      contributor = Contributor.new
      assert_not contributor.valid?
      assert_equal [:district_id, :affiliation_id], contributor.errors.keys
    end

  end
end

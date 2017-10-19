require 'test_helper'

class AffiliationTest < ActiveSupport::TestCase

  test "should have the necessary required validators" do
    affiliation = Affiliation.new
    assert_not affiliation.valid?
    assert_equal [:resident_id, :affiliate_id], affiliation.errors.keys
  end

end

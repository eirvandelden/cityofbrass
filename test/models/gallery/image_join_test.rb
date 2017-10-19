require 'test_helper'

module Gallery
  class ImageJoinTest < ActiveSupport::TestCase

    test "resident should have the necessary required validators" do
      image_join = ImageJoin.new
      assert_not image_join.valid?
      assert_equal [:imageable_type], image_join.errors.keys
    end

  end
end

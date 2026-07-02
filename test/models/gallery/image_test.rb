require 'test_helper'

module Gallery
  class ImageTest < ActiveSupport::TestCase

    test "resident should have the necessary required validators" do
      image = ResidentImage.new(name: "ResidentTest")
      assert_not image.valid?
      assert_equal [:resident, :resident_id, :file], image.errors.keys
    end

    test "stock should have the necessary required validators" do
      image = StockImage.new(name: "StockTest")
      assert_not image.valid?
      assert_equal [:file], image.errors.keys
    end

    test "map should have the necessary required validators" do
      image = MapImage.new(name: "MapTest")
      assert_not image.valid?
      assert_equal [:file], image.errors.keys
    end

    test "faq should have the necessary required validators" do
      image = FaqImage.new(name: "FaqTest")
      assert_not image.valid?
      assert_equal [:file], image.errors.keys
    end

    test "kt-paperclip gem is loaded (not upstream paperclip)" do
      spec = Gem.loaded_specs["kt-paperclip"]
      assert spec, "kt-paperclip gem not loaded — is paperclip still in Gemfile?"
    end

  end
end

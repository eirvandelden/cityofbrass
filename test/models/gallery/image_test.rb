require 'test_helper'

module Gallery
  class ImageTest < ActiveSupport::TestCase

    test "resident should have the necessary required validators" do
      image = ResidentImage.new(name: "ResidentTest")
      assert_not image.valid?
      assert_equal [:file, :resident, :resident_id].sort, image.errors.attribute_names.sort
    end

    test "stock should have the necessary required validators" do
      image = StockImage.new(name: "StockTest")
      assert_not image.valid?
      assert_equal [:file], image.errors.attribute_names
    end

    test "map should have the necessary required validators" do
      image = MapImage.new(name: "MapTest")
      assert_not image.valid?
      assert_equal [:file], image.errors.attribute_names
    end

    test "faq should have the necessary required validators" do
      image = FaqImage.new(name: "FaqTest")
      assert_not image.valid?
      assert_equal [:file], image.errors.attribute_names
    end

    test "find_in_collection finds the image under its own segment" do
      image = gallery_images(:faq_one)

      assert_equal image, Image.find_in_collection("faq_images", image.id)
    end

    test "find_in_collection returns nil for an unknown segment" do
      assert_nil Image.find_in_collection("unknown_things", gallery_images(:faq_one).id)
    end

    test "find_in_collection does not find an image under another collection" do
      assert_nil Image.find_in_collection("stock_images", gallery_images(:faq_one).id)
    end

    test "find_in_collection runs no query for an unknown collection" do
      id = gallery_images(:faq_one).id

      assert_queries_count(0) { Image.find_in_collection("unknown_things", id) }
    end

    test "find_in_collection runs one query for a known collection" do
      id = gallery_images(:faq_one).id

      assert_queries_count(1) { Image.find_in_collection("faq_images", id) }
    end

    test "find_in_collection finds each image type under the segment its file_url uses" do
      [ :resident_one, :stock_one, :map_one, :faq_one ].each do |name|
        image = gallery_images(name)
        segment = image.file_url(:original).split("/")[3]

        assert_equal image, Image.find_in_collection(segment, image.id)
      end
    end

    test "kt-paperclip gem is loaded (not upstream paperclip)" do
      spec = Gem.loaded_specs["kt-paperclip"]
      assert spec, "kt-paperclip gem not loaded — is paperclip still in Gemfile?"
    end

  end
end

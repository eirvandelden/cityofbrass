require 'test_helper'

module Storybuilder
  class PageTest < ActiveSupport::TestCase
    test "should have the necessary required validators" do
      page = Page.new(name: "PageName")
      assert_not page.valid?
      assert_equal [:adventure, :adventure_id, :privacy], page.errors.keys
    end

    test "tag_list returns a comma separated list" do
      assert_equal "hello, world", storybuilder_pages(:page_one).tag_list
    end

    test "tag scopes match exact tags" do
      exact = Page.create!(
        adventure: storybuilder_adventures(:resident_one),
        name: "Art Page",
        privacy: "Residents",
        tags: ["art", "city"]
      )

      Page.create!(
        adventure: storybuilder_adventures(:resident_one),
        name: "Martial Arts Page",
        privacy: "Residents",
        tags: ["martial arts", "city"]
      )

      assert_equal [exact], Page.any_tags(["art"]).to_a
      assert_equal [exact], Page.all_tags(["art", "city"]).to_a
    end
  end
end

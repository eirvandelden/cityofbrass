require 'test_helper'

module Worldbuilder
  class PageTest < ActiveSupport::TestCase
    test "should have the necessary required validators" do
      page = Page.new(name: "PageName")
      assert_not page.valid?
      assert_equal [:district, :district_id], page.errors.keys
    end

    test "tag_list returns a comma separated list" do
      assert_equal "hello1, world2", worldbuilder_pages(:page_one).tag_list
    end

    test "tag scopes match exact tags" do
      exact = Page.create!(
        district: worldbuilder_districts(:district_one),
        name: "Art Page",
        tags: ["art", "city"]
      )

      Page.create!(
        district: worldbuilder_districts(:district_one),
        name: "Martial Arts Page",
        tags: ["martial arts", "city"]
      )

      assert_equal [exact], Page.any_tags(["art"]).to_a
      assert_equal [exact], Page.all_tags(["art", "city"]).to_a
    end
  end
end

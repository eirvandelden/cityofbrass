require 'test_helper'

module Entitybuilder
  class EntityTest < ActiveSupport::TestCase
    test "tag_list returns a comma separated list" do
      assert_equal "hello1, world2", entitybuilder_entities(:resident_character_one).tag_list
    end
  end
end

require "test_helper"

class StorybuilderTest < ActiveSupport::TestCase
  test "loads the engine" do
    assert_kind_of Module, Storybuilder
    assert_operator Storybuilder::Engine, :<, Rails::Engine
  end
end

require 'test_helper'

module Entitybuilder
  class DescriptorTest < ActiveSupport::TestCase

    test "resident should have the necessary required validators" do
      descriptor = Descriptor.new
      assert_not descriptor.valid?
      assert_equal [:name], descriptor.errors.keys
    end

  end
end

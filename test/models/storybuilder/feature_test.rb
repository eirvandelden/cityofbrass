# frozen_string_literal: false

require 'test_helper'

module Storybuilder
  class FeatureTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      feature = Feature.new(feature_type: "text")
      assert_not feature.valid?
      assert_equal [:featureable_type, :feature_label], feature.errors.keys
    end

  end
end

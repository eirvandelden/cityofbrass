require 'test_helper'

module Support
  class FaqTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      faq = Faq.new
      assert_not faq.valid?
      assert_equal [:question], faq.errors.keys
    end

  end
end

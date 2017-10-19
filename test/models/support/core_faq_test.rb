require 'test_helper'

module Support
  class CoreFaqTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      core_faq = CoreFaq.new
      assert_not core_faq.valid?
      assert_equal [:faq_id, :core_item], core_faq.errors.keys
    end

  end
end

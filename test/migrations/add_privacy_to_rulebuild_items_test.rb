require "test_helper"
require Rails.root.join("engines/rulebuilder/db/migrate/20260613000000_add_privacy_to_rulebuild_items")

class AddPrivacyToRulebuildItemsTest < ActiveSupport::TestCase
  test "backfills existing stock items to public" do
    Rulebuilder::Item.update_all(privacy: "Private")

    AddPrivacyToRulebuildItems.new.send(:backfill_existing_stock_items)

    assert_equal [ "Public" ], Rulebuilder::StockItem.distinct.pluck(:privacy)
    assert_equal [ "Private" ], Rulebuilder::ResidentItem.distinct.pluck(:privacy)
  end
end

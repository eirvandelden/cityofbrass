class AddPageDateToCampaignmanagerPages < ActiveRecord::Migration[4.2]
  def change
    add_column :campaignmanager_pages, :page_date, :date
  end
end

# frozen_string_literal: false

class AddPageDateToCampaignmanagerPages < ActiveRecord::Migration
  def change
    add_column :campaignmanager_pages, :page_date, :date
  end
end

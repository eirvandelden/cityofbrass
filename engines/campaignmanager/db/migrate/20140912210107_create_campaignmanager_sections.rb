# frozen_string_literal: false

class CreateCampaignmanagerSections < ActiveRecord::Migration
  def change
    create_table :campaignmanager_sections, id: :uuid do |t|
      t.uuid :sectionable_id
      t.string :sectionable_type
      t.integer :sort_order
      t.string :header
      t.text :content
      t.string :section_type
      t.string :section_style
      t.string :record_type
      t.string :search_tags

      t.timestamps
    end

    add_index :campaignmanager_sections, [:sectionable_id, :sectionable_type], :name => 'index_campaignmanager_sections_id_and_type'
  end
end

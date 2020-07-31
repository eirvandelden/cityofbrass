# frozen_string_literal: false

class AddSheetPrivacyToEntitybuilderCreature < ActiveRecord::Migration
  def change
    add_column :entitybuilder_creatures, :sheet_privacy, :string
  end
end

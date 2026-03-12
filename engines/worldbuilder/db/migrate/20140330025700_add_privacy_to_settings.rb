class AddPrivacyToSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :worldbuilder_settings, :privacy, :string, default: 'public'
  end
end

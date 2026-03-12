class AddOriginalModType < ActiveRecord::Migration[4.2]
  def change
    add_column :entitybuilder_modifiers, :original_mod_type, :string
  end
end

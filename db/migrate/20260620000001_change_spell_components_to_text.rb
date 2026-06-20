class ChangeSpellComponentsToText < ActiveRecord::Migration[6.1]
  def up
    change_column :rulebuilder_spells, :components, :text
  end

  def down
    change_column :rulebuilder_spells, :components, :string
  end
end

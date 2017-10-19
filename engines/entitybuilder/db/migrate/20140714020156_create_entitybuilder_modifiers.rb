class CreateEntitybuilderModifiers < ActiveRecord::Migration
  def change
    create_table :entitybuilder_modifiers, id: :uuid do |t|
      t.uuid :modifierable_id
      t.string :modifierable_type
      t.uuid :entityable_id
      t.string :entityable_type
      t.integer :sort_order
      t.string :category
      t.string :item
      t.integer :value
      t.string :dice

      t.timestamps
    end

    add_index :entitybuilder_modifiers, [:modifierable_id, :modifierable_type], :name => 'eb_modifier_id_and_type'
    add_index :entitybuilder_modifiers, [:entityable_id, :entityable_type], :name => 'eb_modifier_entity_id_and_type'
  end
end

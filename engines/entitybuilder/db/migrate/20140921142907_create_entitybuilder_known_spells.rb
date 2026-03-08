class CreateEntitybuilderKnownSpells < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_known_spells, id: :string do |t|
      t.string :known_spellable_id
      t.string :known_spellable_type
      t.integer :sort_order
      t.string :spell_id
      t.boolean :prepared
      t.boolean :used

      t.timestamps
    end

    add_index :entitybuilder_known_spells, :spell_id
    add_index :entitybuilder_known_spells, [ :known_spellable_id, :known_spellable_type ], name: 'eb_known_spell_id_and_type'
  end
end

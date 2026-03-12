class CreateEntitybuilderSpells < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_spells, id: :string do |t|
      t.string :spellable_id
      t.string :spellable_type
      t.integer :sort_order
      t.string :name, null: false
      t.string :short_description
      t.text :full_description
      t.string :school
      t.integer :level
      t.string :casting_time
      t.string :components
      t.string :range
      t.string :effect
      t.string :target
      t.string :area
      t.string :duration
      t.string :saving_throw

      t.timestamps
    end

    add_index :entitybuilder_spells, [ :spellable_id, :spellable_type ], name: 'eb_spell_id_and_type'
    add_index :entitybuilder_spells, [ :spellable_id, :name ], unique: true, name: 'eb_spell_name'
  end
end

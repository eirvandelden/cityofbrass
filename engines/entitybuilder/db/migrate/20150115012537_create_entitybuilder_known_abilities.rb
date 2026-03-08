class CreateEntitybuilderKnownAbilities < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_known_abilities, id: :string do |t|
      t.string :known_abilityable_id
      t.string :known_abilityable_type
      t.integer :sort_order
      t.string :ability_id

      t.timestamps null: false
    end

    add_index :entitybuilder_known_abilities, :ability_id
    add_index :entitybuilder_known_abilities, [ :known_abilityable_id, :known_abilityable_type ], name: 'eb_known_ability_id_and_type'
  end
end

class CreateEntitybuilderAbilityScores < ActiveRecord::Migration
  def change
    create_table :entitybuilder_ability_scores, id: :uuid do |t|
      t.uuid :ability_scoreable_id
      t.string :ability_scoreable_type
      t.integer :sort_order
      t.string :name, :null => false
      t.text :description
      t.integer :base
      t.integer :score
      t.integer :modifier
      t.string :dice

      t.timestamps
    end

    add_index :entitybuilder_ability_scores, [:ability_scoreable_id, :ability_scoreable_type], :name => 'eb_ability_score_id_and_type'
    add_index :entitybuilder_ability_scores, [:ability_scoreable_id, :name], :unique => true, :name => 'eb_ability_score_name'
  end
end

class RemovePolymorphicFromAll < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_ability_scores, :name =>  'eb_ability_score_id_and_type'
    remove_index :entitybuilder_ability_scores, :name =>  'eb_ability_score_name'

    rename_column :entitybuilder_ability_scores, :ability_scoreable_id, :entity_id

    add_index :entitybuilder_ability_scores, :entity_id
  end
end

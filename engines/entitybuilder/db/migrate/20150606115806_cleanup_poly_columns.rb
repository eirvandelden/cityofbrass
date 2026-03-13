class CleanupPolyColumns < ActiveRecord::Migration
  def change
    remove_column :entitybuilder_ability_scores, :ability_scoreable_type, :string
    remove_column :entitybuilder_attacks, :attackable_type, :string
    remove_column :entitybuilder_base_values, :base_valueable_type, :string
    remove_column :entitybuilder_campaign_joins, :campaign_joinable_type, :string
    remove_column :entitybuilder_caster_levels, :caster_levelable_type, :string
    remove_column :entitybuilder_class_levels, :class_levelable_type, :string
    remove_column :entitybuilder_currencies, :currencyable_type, :string
    remove_column :entitybuilder_defenses, :defenseable_type, :string
    remove_column :entitybuilder_descriptors, :descriptorable_type, :string
    remove_column :entitybuilder_inventory_items, :inventory_itemable_type, :string
    remove_column :entitybuilder_known_abilities, :known_abilityable_type, :string
    remove_column :entitybuilder_known_feats, :known_featable_type, :string
    remove_column :entitybuilder_known_spells, :known_spellable_type, :string
    remove_column :entitybuilder_modifiers, :entityable_type, :string
    remove_column :entitybuilder_movements, :movementable_type, :string
    remove_column :entitybuilder_saving_throws, :saving_throwable_type, :string
    remove_column :entitybuilder_skills, :skillable_type, :string
    remove_column :entitybuilder_trackables, :trackableable_type, :string
    remove_column :entitybuilder_traits, :traitable_type, :string
  end
end

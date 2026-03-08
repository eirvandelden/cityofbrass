class RemoveFeatureStyleFromFeatures < ActiveRecord::Migration[4.2]
  def change
    remove_column :worldbuilder_features, :feature_style, :string
  end
end

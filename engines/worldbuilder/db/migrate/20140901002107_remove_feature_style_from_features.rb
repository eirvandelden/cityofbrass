# frozen_string_literal: false

class RemoveFeatureStyleFromFeatures < ActiveRecord::Migration
  def change
    remove_column :worldbuilder_features, :feature_style, :string
  end
end

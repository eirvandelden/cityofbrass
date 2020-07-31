# frozen_string_literal: false

class DropResourceTables < ActiveRecord::Migration
  def change
    drop_table :resources_image_joins
    drop_table :resources_images
  end
end

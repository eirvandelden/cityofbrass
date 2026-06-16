class AddBadgesToResidents < ActiveRecord::Migration[4.2]
  def change
    add_column :residents, :badges, :text
  end
end

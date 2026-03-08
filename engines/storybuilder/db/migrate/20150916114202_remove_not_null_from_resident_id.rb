class RemoveNotNullFromResidentId < ActiveRecord::Migration[4.2]
  def change
    change_column_null :storybuilder_adventures, :resident_id, true
  end
end

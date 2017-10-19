class RemoveNotNullFromResidentId < ActiveRecord::Migration
  def change
    change_column_null :storybuilder_adventures, :resident_id, true
  end
end

class EnsureLocaleOnUsers < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :locale, :string, null: false, default: "en" unless column_exists?(:users, :locale)
  end

  def down
    remove_column :users, :locale if column_exists?(:users, :locale)
  end
end

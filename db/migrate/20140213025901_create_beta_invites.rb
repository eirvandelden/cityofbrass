class CreateBetaInvites < ActiveRecord::Migration
  def change
    create_table :beta_invites, id: :uuid  do |t|
      t.string :email

      t.timestamps
    end

    add_index :beta_invites, :email, :unique => true
  end
end

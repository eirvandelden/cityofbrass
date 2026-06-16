class CreateBetaInvites < ActiveRecord::Migration[4.2]
  def change
    create_table :beta_invites, id: :string  do |t|
      t.string :email

      t.timestamps
    end

    add_index :beta_invites, :email, :unique => true
  end
end

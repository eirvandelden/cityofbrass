class CreateBillingPlans < ActiveRecord::Migration[4.2]
  def change
    create_table :billing_plans, id: :string do |t|
      t.string :name, null: false
      t.string :stripe_plan_token
      t.string :interval
      t.integer :interval_count
      t.string :currency
      t.integer :amount
      t.string :description
      t.boolean :active

      t.timestamps null: false
    end
  end
end

class CreateSupportCoreFaqs < ActiveRecord::Migration[4.2]
  def change
    create_table :support_core_faqs, id: :string do |t|
      t.string :faq_id, null: false
      t.string :core_item, null: false
      t.boolean :active, null: false

      t.timestamps null: false
    end
  end
end

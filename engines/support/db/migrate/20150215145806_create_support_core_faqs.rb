class CreateSupportCoreFaqs < ActiveRecord::Migration
  def change
    create_table :support_core_faqs, id: :uuid do |t|
      t.uuid :faq_id, :null => false
      t.string :core_item, :null => false
      t.boolean :active, :null => false

      t.timestamps null: false
    end
  end
end

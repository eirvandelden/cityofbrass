class CreateSupportFaqs < ActiveRecord::Migration[4.2]
  def change
    create_table :support_faqs, id: :string do |t|
      t.string :topic
      t.string :question, null: false
      t.text :answer
      t.boolean :active, null: false

      t.timestamps
    end
  end
end

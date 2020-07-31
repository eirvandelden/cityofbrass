# frozen_string_literal: false

class CreateSupportFaqs < ActiveRecord::Migration
  def change
    create_table :support_faqs, id: :uuid do |t|
      t.string :topic
      t.string :question, :null => false
      t.text :answer
      t.boolean :active, :null => false

      t.timestamps
    end
  end
end

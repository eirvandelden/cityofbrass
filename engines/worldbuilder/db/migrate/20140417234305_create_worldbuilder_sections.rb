class CreateWorldbuilderSections < ActiveRecord::Migration[4.2]
  def change
    create_table :worldbuilder_sections, id: :string do |t|
      t.string :sectionable_id
      t.string :sectionable_type
      t.integer :sort_order
      t.string :header
      t.text :content
      t.string :section_type
      t.string :section_style
      t.string :record_type
      t.string :search_tags

      t.timestamps
    end

    add_index :worldbuilder_sections, [ :sectionable_id, :sectionable_type ], name: 'index_worldbuilder_sections_id_and_type'
  end
end

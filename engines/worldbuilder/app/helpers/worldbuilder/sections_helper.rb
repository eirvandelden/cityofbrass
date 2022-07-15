module Worldbuilder
  module SectionsHelper
    def wb_section_text_style_options
      [
        ['Paragraph', 'paragraph'],
        ['Private Notes', 'private_notes'],
        ['Readaloud', 'readaloud'],
        ['Sidebar', 'sidebar']
      ]
    end

    def wb_section_list_style_options
      [
        ['Blocks', 'blocks'],
        ['Bulleted', 'bulleted'],
        ['Standard', 'standard']
      ]
    end
  end
end

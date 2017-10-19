module Campaignmanager
  module SectionsHelper
    def cm_section_text_style_options
      section_options = [
        ['Paragraph', 'paragraph'],
        ['Private Notes', 'private_notes'],
        ['Readaloud', 'readaloud'],
        ['Sidebar', 'sidebar']
      ]
    end

    def cm_section_list_style_options
      section_options = [
        ['Blocks', 'blocks'],
        ['Bulleted', 'bulleted'],
        ['Standard', 'standard']
      ]
    end
  end
end

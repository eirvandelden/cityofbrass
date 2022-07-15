module Worldbuilder
  module DistrictsHelper

    def child_options_district
      [
      ]
    end

    def feature_special_options_district
      [
        'Created',
        'Updated',
        'Owner'
      ]
    end

    def wb_district_mockup(district)

      menu_item_ids = []

      ActiveRecord::Base.transaction do
        menu_items = wb_menu_item_mockup_records
        menu_items.each_with_index do |r,i|
          menu_item =  district.menu_items.new
          menu_item.item_label  = r[:item_label]
          menu_item.item_link = "/wb/#{district.slug}#{r[:item_link]}"
          menu_item.sort_order = i
          menu_item.save(:validate => true)
          menu_item_ids[i] = menu_item.id
        end

        pages = wb_page_mockup_records
        pages.each_with_index do |r,i|
          page =  district.pages.new
          page.name  = r[:name]
          page.short_description = r[:short_description]
          page.full_description  = r[:full_description]
          page.save(:validate => true)

          menu_item_join = page.build_menu_item_join
          menu_item_join.menu_item_id = menu_item_ids[i]
          menu_item_join.save(:validate => true)

          section = page.sections.new
          section.sort_order = 0
          section.section_type = "child"
          section.section_style = "blocks"
          section.save(:validate => true)
        end
      end

    end

    def wb_menu_item_mockup_records
      [
        {item_label: 'Atlas', item_link: '/pages/atlas'},
        {item_label: 'People', item_link: '/pages/people'},
        {item_label: 'History', item_link: '/pages/history'}
      ]
    end

    def wb_page_mockup_records
      'https://www.#{ENV['DEFAULT_BASE_URL']}/wb/korinth/lore_records/history'>Korinth's History</a> to see an example of how you might build your histories. </p>
              <p>Good luck and thanks for choosing City of Brass! </p>
            "
        }
      ]
    end

  end
end

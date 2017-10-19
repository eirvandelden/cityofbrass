module Worldbuilder
  module DistrictsHelper

    def child_options_district
      child_options = [
      ]
    end

    def feature_special_options_district
      special_options = [
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
      options = [
        {item_label: 'Atlas', item_link: '/pages/atlas'},
        {item_label: 'People', item_link: '/pages/people'},
        {item_label: 'History', item_link: '/pages/history'}
      ]
    end

    def wb_page_mockup_records
      options = [
        {
            name: "Atlas",
            short_description: "Use this page to organize the places in your world.",
            full_description: "
              <blockquote>
              <p>This is your Atlas. Why not add a new continent by clicking that ( <strong>+</strong> ) up there in the top right? </p>
              </blockquote>
              <p>The Atlas is where you build your world's planets, continents, nations, cities, inns, taverns, and all the places your characters might want to visit when playing the game. </p>
              <p>You might not realize it, but we have a bunch of stock artwork and maps you can use on your pages. You can find them when you go to pick the image for your page. To the right of your <strong>My Images</strong> link is another choice for <strong>Stock Images</strong> and <strong>Map Images.</strong></p>
              <p>Check out the <a href='https://www.#{ENV['DEFAULT_BASE_URL']}/wb/valley-of-the-kings/atlas_entries/places'>places in the Valley of the Kings District</a> to see an example of an Atlas. </p>
              <p>Happy world building! </p>
            "
        },
        {
            name: "People",
            short_description: "Use this page to keep track of the people that live in your world.",
            full_description: "
              <blockquote>
              <p>It's kind of lonely around here. Add a new person to your world by clicking that ( <strong>+</strong> )in the upper right. </p>
              </blockquote>
              <p>Your game world is probably full of unique and exciting people, organizations, guilds, races, species, and more. Add them all here under inhabitants so people can find them. </p>
              <p>And don't forget, we have loads of pictures of people you can use in our stock image library. </p>
              <p>Check out the <a href='https://www.#{ENV['DEFAULT_BASE_URL']}/wb/realm-of-the-gods/inhabitants/inhabitants-of-aedryn'>inhabitants of the Realm of the Gods</a> to see an example of how to use People. </p>
            "
        },
        {
            name: "History",
            short_description: "Use this page to tell the story of your world.",
            full_description: "
              <blockquote>
              <p>Tell me more about this place you've created by creating a new history record with the ( <strong>+</strong> ) up there! </p>
              </blockquote>
              <p>The history of your world is where you can really bring it to life. Tell us about what has forged it into the place you know and love. Who are its heroes and how are they remembered? </p>
              <p>Use History to paint the canvas of your world. </p>
              <p>Check out <a href='https://www.#{ENV['DEFAULT_BASE_URL']}/wb/korinth/lore_records/history'>Korinth's History</a> to see an example of how you might build your histories. </p>
              <p>Good luck and thanks for choosing City of Brass! </p>
            "
        }
      ]
    end

  end
end

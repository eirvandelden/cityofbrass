module ApplicationHelper

  def tooltip_helper(tooltip)
    return "<span data-tooltip aria-haspopup='true' class='has-tip question-mark' title=\"#{tooltip}\"><i class='fa fa-question-circle'></i></span>".html_safe
  end

  def name_scrubber(name)
    scrubbed = name.gsub(/[^0-9A-Za-z \-\(\)\[\]\']/, ' ')
    return scrubbed
  end

  def can_add(user, type)
    return false if user.nil?
    return true if type.include?"Resident"
    return true if type.exclude?"Resident" and admin_signed_in?
    false
  end

  def active_menu_item(menu_item, page=nil, menu_link=nil)
    return 'active' if !page.nil? && menu_item.id==page.menu_item_id
    return 'active' if current_page?(menu_link)
    return nil
  end

  def type_split(type)
    return type.tableize.titleize.split(' ')
  end

  def full_title(page_title)
    base_title = "City of Brass"
    if page_title.empty?
      base_title
    else
      ("#{base_title} | #{page_title}").gsub('&#39;', "'")
    end
  end

  def city_path(parent, page)
    send "#{parent.class.to_s.demodulize.underscore}_#{page.class.to_s.demodulize.underscore}_path", parent, page
  end

  def edit_city_path(parent, page)
    send "edit_#{parent.class.to_s.demodulize.underscore}_#{page.class.to_s.demodulize.underscore}_path", parent, page
  end

  def new_city_path(parent, page_type)
    send "new_#{parent.class.to_s.demodulize.underscore}_#{page_type}_path", parent
  end

  def tcob_path(record, link_type = "slug")
    begin
      base_link = record.class.to_s.underscore
      record_type = "resident"
      record_type = "stock" if base_link.include?("stock")
      record_type = "proprietary" if base_link.include?("proprietary")
      link_type = 'id' if base_link.include?("entitybuilder")

      if base_link.include?("worldbuilder")
        if base_link.include?("worldbuilder/district")
          base_link = '/wb/'
        else
          base_link = '/wb/' + record.district.slug + '/' + base_link.gsub('worldbuilder/','').pluralize + '/'
        end
      end

      if base_link.include?("storybuilder")
        link_type = 'id'
        if base_link.include?("adventure")
          base_link = "/sb/#{record_type}/adventures/"
        else
          type_array = type_split(record.adventure.type.demodulize)
          base_link = "/sb/#{type_array[0].downcase}/adventures/#{record.adventure_id}/#{base_link.gsub('storybuilder/','').pluralize }/"
          #base_link = '/sb/resident/adventures/' + record.adventure_id + '/' + base_link.gsub('storybuilder/','').pluralize + '/'
        end
      end

      if base_link.include?("campaignmanager")
        link_type = 'id'
        if base_link == "campaignmanager/campaign"
          base_link = '/cm/campaigns/'
        else
          base_link = '/cm/campaigns/' + record.campaign_id + '/' + base_link.gsub('campaignmanager/','').pluralize + '/'
        end
      end

      base_link = '/residents/' + record.resident.slug + '/eb/' + base_link.gsub('entitybuilder/','').pluralize + '/' if base_link.include?("entitybuilder")
      return "#{base_link}#{record.slug}" if link_type == 'slug'
      return "#{base_link}#{record.id}" if link_type == 'id'
    rescue => e
      logger.error "tcob_path ERROR: #{e.message}"
    end
  end

  def edit_tcob_path(record)
    return "#{tcob_path(record, 'id')}/edit"
  end

  def tcob_sentence(list)
    begin
      buildlist = []
      if list
        list.each do |record|
          link = link_to record.name, tcob_path(record)
          buildlist << link
        end
        buildlist.to_sentence(:two_words_connector => ' & ', :last_word_connector => ' & ').html_safe
      else
        nil
      end
    rescue => e
      logger.error "tcob_sentence ERROR: #{e.message}"
    end
  end

  def notable_sentence(list)
    begin
      buildlist = []
      if list
        list.each do |record|

        if record.entity.blank?
          link = record.name
        elsif  record.notableable_type.include?"Storybuilder"
          link = link_to record.name, "#{entitybuilder.polymorphic_path(record.entity)}/profile", "data-reveal-id" => "showModal", :remote => true
        else
          link = link_to record.name, "#{entitybuilder.polymorphic_path(record.entity)}", "data-reveal-id" => "showModal", :remote => true
        end
          buildlist << link
        end
        buildlist.to_sentence(:two_words_connector => ' & ', :last_word_connector => ' & ').html_safe
      else
        nil
      end
    rescue => e
      logger.error "notable_sentence ERROR: #{e.message}"
    end
  end

# ==== REDCARPET GEM ===== #
  def markdown(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      :filter_html => true,
      :autolink => true,
      :space_after_headers => true,
      :tables => true,
      :safe_links_only => true,
      :with_toc_data => true
      )
    markdown.render(text)
  end

# ===== BREAD CRUMBS ===== #
  def breadcrumb_str options
    items = []
    if(options.size !=0 )
      #items <<  content_tag(:li, :class => "unavailable") do
      #  link_to("City of Brass", root_path)
      #end
      options.each do |option|
        option.each do |key, value|
          unless value.nil?
            items << content_tag(:li) do
              link_to(key, value)
            end
          else
            items <<  content_tag(:li, :class => "current") do
              key
            end
          end
        end
      end
    #else
      #items << content_tag(:li, "City of Brass", :class => "current")
    end

    items.join("").html_safe
  end

  def breadcrumb options
    content_tag(:ul, breadcrumb_str(options), :class => "breadcrumbs")
  end

end

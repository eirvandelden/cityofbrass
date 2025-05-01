module ResidentsHelper

  def resident_badges
    [
      {badge: "Owner", color: "badge-secondary", url: "https://www.embersds.com"},
      {badge: "System", color: "badge-secondary", url: ""},
      {badge: "Founder", color: "badge-secondary", url: ""},
      {badge: "Kickstarter", color: "badge-kickstarter", url: "https://www.kickstarter.com/projects/embersdesignstudios/the-city-of-brass-web-based-tabletop-rpg-app/description"},
      {badge: "Book of Terniel", color: "badge-kickstarter", url: ""},
      {badge: "Lore Seeker", color: "badge-kickstarter", url: ""},
      {badge: "Yrisa's Nightmare", color: "badge-kickstarter",url: ""},
      {badge: "Nightmare Dreamer", color: "badge-kickstarter",url: ""}
    ]
  end

  def badge_formatter(badges)
    begin
      items = []
      badges.each do |badge|
        b = resident_badges.select { |v| v[:badge] == badge.strip }
        if b.any?
          if b[0][:url].present?
            items << "<a href='#{b[0][:url]}' target='badge' class='label #{b[0][:color]}-link'>#{badge}</a> "
          else
            items << "<span class='label #{b[0][:color]}'>#{badge}</span> "
          end
        else
          items << "<span class='label badge-primary'>#{badge}</span> "
        end
      end
      items.join("").html_safe
    rescue => e
      logger.error "badge_formatter ERROR: #{e.message}"
    end
  end
end

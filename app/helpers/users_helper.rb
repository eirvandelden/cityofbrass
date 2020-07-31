# frozen_string_literal: false

module UsersHelper
  def status_style(status)
    case status
      when 'active'
        "color:#008cdd;"
      when 'canceled'
        "color:#c5c5c5;"
      when 'locked'
        "color:#ff5800; font-weight: bold;"
      when 'trial'
        "color:#adc6ee;"
      when 'beta'
        "color:#007a00; font-weight: bold;"
      when 'free'
        "color:#000; font-style: italic;"
      else
        "color:#000"
    end
  end

end

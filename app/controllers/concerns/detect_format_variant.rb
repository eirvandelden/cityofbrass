module DetectFormatVariant
  extend ActiveSupport::Concern

  included do
    before_action :detect_device
  end

  private
    def detect_device
      #request.variant = :phone
      case request.user_agent
        when /ip(hone|od)/i
          request.variant = :phone
        when /windows phone/i
          request.variant = :phone
        when /blackberry/i
          request.variant = :phone
        when /bb10/i
          request.variant = :phone
        when /android.+mobile/i
          request.variant = :phone
        when /nokia.+mobile/i
          request.variant = :phone
        else
          request.variant = :desktop
      end
    end
end

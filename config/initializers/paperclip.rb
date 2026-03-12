# Patch Paperclip 6.1.0 for Ruby 3.x compatibility: URI.escape was removed in Ruby 3.0.
# Use URI::DEFAULT_PARSER.escape as the replacement.
module Paperclip
  class UrlGenerator
    def escape_url(url)
      if url.respond_to?(:escape)
        url.escape
      else
        URI::DEFAULT_PARSER.escape(url).gsub(/[\?\(\)\[\]\+]/) { |m| "%#{m.ord.to_s(16).upcase}" }
      end
    end
  end

  class HttpUrlProxyAdapter < UriAdapter
    def initialize(target, options = {})
      escaped = URI::DEFAULT_PARSER.escape(target)
      super(URI(target == URI::DEFAULT_PARSER.unescape(target) ? escaped : target), options)
    end
  end
end

module Paperclip
  module Interpolations
    def part_id(attachment, style_name)
      part = attachment.instance.resident_id[0, 1]
      part << "/"
      part << attachment.instance.resident_id[1, 1]
      part << "/"
      part << attachment.instance.resident_id[2, 1]
    end
    def resident_id(attachment, style_name)
      attachment.instance.resident_id
    end
  end
end

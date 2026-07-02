Paperclip.options[:content_type_mappings][:xml] = %w[application/xml text/xml]

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

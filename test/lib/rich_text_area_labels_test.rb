require "test_helper"

class RichTextAreaLabelsTest < ActiveSupport::TestCase
  test "rich text areas have explicit labels" do
    view_paths = Rails.root.glob("{app/views,engines/*/app/views}/**/*.{erb,html.erb}")

    view_paths.each do |path|
      lines = path.readlines

      lines.each_with_index do |line, index|
        next unless line =~ /rich_text_area\s+:(\w+)/

        attribute = Regexp.last_match(1)
        previous_line = lines[0...index].reverse.find { |candidate| candidate.strip.present? }

        assert_match(/f\.label\s+:#{attribute}\b/, previous_line, "#{path}:#{index + 1} is missing a label")
      end
    end
  end
end

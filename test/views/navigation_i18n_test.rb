require "test_helper"

class NavigationI18nTest < ActiveSupport::TestCase
  NAVIGATION_PARTIALS = Rails.root.glob("app/views/layouts/navigation/*.erb").freeze

  test "navigation partials do not hardcode visible text" do
    offenders = NAVIGATION_PARTIALS.flat_map { |partial| hardcoded_text_in(partial) }

    assert_empty offenders
  end

  private

  def hardcoded_text_in(partial)
    partial.readlines.each_with_index.flat_map do |line, index|
      visible_text_nodes(line).map do |text|
        "#{partial.relative_path_from(Rails.root)}:#{index + 1}: #{text}"
      end
    end
  end

  def visible_text_nodes(line)
    line_without_erb = line.gsub(/<%=?[^%]*%>/, "")
    text_nodes(line_without_erb) + link_to_literals(line_without_erb)
  end

  def text_nodes(line)
    line.scan(/>\s*([^<%>]*[[:alpha:]][^<%>]*)\s*</).flatten.map(&:strip)
  end

  def link_to_literals(line)
    line.scan(/link_to\s+["']([^"']*[[:alpha:]][^"']*)["']/).flatten.map do |text|
      text.gsub(/<[^>]+>/, "").squish
    end
  end
end

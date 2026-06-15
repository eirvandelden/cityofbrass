require "test_helper"

class ImporterI18nTest < ActiveSupport::TestCase
  IMPORTER_VIEWS = Rails.root.glob("engines/importer/app/views/**/*.erb").freeze

  test "importer views do not hardcode title attributes" do
    offenders = IMPORTER_VIEWS.flat_map { |view| hardcoded_title_attributes_in(view) }

    assert_empty offenders
  end

  private

  def hardcoded_title_attributes_in(view)
    view.readlines.each_with_index.flat_map do |line, index|
      line.scan(/title:\s*["']([^"']*[[:alpha:]][^"']*)["']/).flatten.map do |text|
        "#{view.relative_path_from(Rails.root)}:#{index + 1}: #{text}"
      end
    end
  end
end

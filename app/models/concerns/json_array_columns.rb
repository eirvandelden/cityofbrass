require "json"
require "yaml"

module JsonArrayColumns
  extend ActiveSupport::Concern

  class_methods do
    def json_array_column(*columns)
      columns.each do |column|
        define_method(column) do
          parse_json_array(read_attribute(column))
        end

        define_method("#{column}=") do |value|
          write_attribute(column, parse_json_array(value).to_json)
        end
      end
    end

    def json_array_contains_any(column, values)
      json_array_scope(column, values, joiner: " OR ", fallback: none)
    end

    def json_array_contains_all(column, values)
      json_array_scope(column, values, joiner: " AND ", fallback: all)
    end

    private

    def json_array_scope(column, values, joiner:, fallback:)
      normalized_values = parse_json_array(values)
      return fallback if normalized_values.empty?

      clauses = normalized_values.map { json_array_clause(column) }
      where(clauses.join(joiner), *normalized_values)
    end

    def json_array_clause(column)
      table = connection.quote_table_name(table_name)
      name = connection.quote_column_name(column)
      source = "CASE WHEN json_valid(COALESCE(#{table}.#{name}, '[]')) " \
               "THEN COALESCE(#{table}.#{name}, '[]') ELSE '[]' END"
      "EXISTS (SELECT 1 FROM json_each(#{source}) WHERE value = ?)"
    end

    def parse_json_array(value)
      case value
      when nil
        []
      when Array
        normalize_array_values(value)
      when String
        return [] if value.blank?

        normalize_array_values(parse_array_string(value))
      else
        normalize_array_values(Array(value))
      end
    rescue JSON::ParserError, Psych::SyntaxError, TypeError
      normalize_array_values(Array(value))
    end

    def normalize_array_values(values)
      Array(values).flatten.compact.map(&:to_s).reject(&:blank?)
    end

    def parse_array_string(value)
      JSON.parse(value)
    rescue JSON::ParserError
      YAML.safe_load(value, permitted_classes: [], aliases: false)
    end
  end

  private

  def parse_json_array(value)
    self.class.send(:parse_json_array, value)
  end
end

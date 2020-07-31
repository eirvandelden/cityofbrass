# frozen_string_literal: false

json.array!(@base_values) do |base_value|
  json.extract! base_value, :name, :value, :dice
end

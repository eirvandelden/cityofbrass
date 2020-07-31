# frozen_string_literal: false

json.array!(@attacks) do |attack|
  json.extract! attack, :name
end

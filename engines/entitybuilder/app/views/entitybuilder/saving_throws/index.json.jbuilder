# frozen_string_literal: false

json.array!(@saving_throws) do |saving_throw|
  json.extract! saving_throw, :name, :bonus, :base, :ability_score, :misc_modifier
end

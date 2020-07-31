# frozen_string_literal: false

json.array!(@skills) do |skill|
  json.extract! skill, :name, :bonus, :class_skill, :ability_score, :ranks, :misc_modifier
end

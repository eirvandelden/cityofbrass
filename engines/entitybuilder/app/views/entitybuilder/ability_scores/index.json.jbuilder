json.array!(@ability_scores) do |ability_score|
  json.extract! ability_score, :name, :score, :modifier, :dice
end

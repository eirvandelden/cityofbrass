json.array!(@defenses) do |defense|
  json.extract! defense, :name, :bonus, :base, :ability_score, :misc_modifier
end

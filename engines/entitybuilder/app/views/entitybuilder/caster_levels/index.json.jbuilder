json.array!(@caster_levels) do |caster_level|
  json.extract! caster_level, :name, :value, :dice
end

json.array!(@attacks) do |attack|
  json.extract! attack, :name
end

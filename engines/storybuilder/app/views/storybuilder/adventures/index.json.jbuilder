json.array!(@adventures) do |adventure|
  json.extract! adventure, :id, :name
  json.path polymorphic_path(adventure)
end

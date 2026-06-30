json.array!(@pages) do |page|
  json.extract! page, :id, :name
  json.path city_path(@parent_object, page)
end

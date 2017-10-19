json.array!(@movements) do |movement|
  json.extract! movement, :name, :bonus, :description
end

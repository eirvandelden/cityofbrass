# frozen_string_literal: false

json.array!(@district_list) do |district|
  json.extract! district, :id, :name, :slug
  json.path worldbuilder.district_path(district.slug)
end

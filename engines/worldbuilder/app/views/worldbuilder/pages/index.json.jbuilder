# frozen_string_literal: false

json.array!(@pages) do |page|
  json.extract! page, :id, :name, :slug
  json.path "/wb/#{@district.slug}/pages/#{page.slug}"
end

# frozen_string_literal: false

json.array!(@pages) do |page|
  json.extract! page, :id, :name
  json.path "/pages/#{page.id}"
end

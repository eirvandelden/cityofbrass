json.array!(@pages) do |page|
  json.extract! page, :id, :name
  json.path "/#{@type.underscore.pluralize}/#{page.id}"
end

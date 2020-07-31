# frozen_string_literal: false

json.array!(@residents) do |resident|
  json.extract! resident, :id, :name, :slug, :short_description
  json.url resident_url(resident.slug, format: :json)
end

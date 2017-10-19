require 'core_rules'

CoreRules.rulebooks = []
Dir["#{Rails.root}/config/core_rules/*.json"].each_with_index do |fname, index|
  CoreRules.rulebooks[index] = JSON.parse(File.read fname)
end

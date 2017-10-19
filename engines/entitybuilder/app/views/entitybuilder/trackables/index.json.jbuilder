json.array!(@trackables) do |trackable|
  json.extract! trackable, :name, :minimum, :maximum, :current, :temporary
end

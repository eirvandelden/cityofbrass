Rulebuilder::Engine.routes.draw do

  resources :rules
  concern :options do
    get '/options', action: :options
  end

  scope '/resident/' do
    resources :resident_items,     path: :items,     concerns: :options
    resources :resident_rules,     path: :rules,     concerns: :options
    resources :resident_spells,    path: :spells,    concerns: :options
  end

  scope '/stock/' do
    resources :stock_items,     path: :items,     concerns: :options
    resources :stock_rules,     path: :rules,     concerns: :options
    resources :stock_spells,    path: :spells,    concerns: :options
  end

  scope '/proprietary/' do
    resources :proprietary_items,     path: :items,     concerns: :options
    resources :proprietary_rules,     path: :rules,     concerns: :options
    resources :proprietary_spells,    path: :spells,    concerns: :options
  end

end

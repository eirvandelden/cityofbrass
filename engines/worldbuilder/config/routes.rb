Worldbuilder::Engine.routes.draw do

  # DRY UP YOUR CONCERNS
  concern :options do
    get '/options', action: :options
  end
  concern :menu_items do
    resources :menu_items
    patch '/menu_items' => 'menu_items#update_list', :as => :update_menu_items
  end
  concern :features do
    resources :features
    patch '/features' => 'features#update_list', :as => :update_features
  end
  concern :sections do
    resources :sections
    patch '/sections' => 'sections#update_list', :as => :update_sections
  end
  concern :adventure do
    get '/adventure/:adventure_id' => 'pages#adventure', as: :adventure
  end
  concern :campaign do
    get '/campaign/:campaign_id' => 'districts#campaign', as: :campaign
  end
  concern :page do
    resources :pages, concerns: [:features, :sections, :options, :adventure]
    get 'pages/new/:parent_id' => 'pages#new', :as => :page_new_child
  end
  concern :legacy do
    get '/atlas_entries', to: 'pages#index'
    get '/atlas_entries/:id', to: 'pages#show'
    get '/atlas_entries/:id/adventure/:adventure_id' => 'pages#adventure'

    get '/deities', to: 'pages#index'
    get '/deities/:id', to: 'pages#show'
    get '/deities/:id/adventure/:adventure_id' => 'pages#adventure'

    get '/house_rules', to: 'pages#index'
    get '/house_rules/:id', to: 'pages#show'
    get '/house_rules/:id/adventure/:adventure_id' => 'pages#adventure'

    get '/inhabitants', to: 'pages#index'
    get '/inhabitants/:id', to: 'pages#show'
    get '/inhabitants/:id/adventure/:adventure_id' => 'pages#adventure'

    get '/lore_records', to: 'pages#index'
    get '/lore_records/:id', to: 'pages#show'
    get '/lore_records/:id/adventure/:adventure_id' => 'pages#adventure'

    get '/planes', to: 'pages#index'
    get '/planes/:id', to: 'pages#show'
    get '/planes/:id/adventure/:adventure_id' => 'pages#adventure'

    get '/religions', to: 'pages#index'
    get '/religions/:id', to: 'pages#show'
    get '/religions/:id/adventure/:adventure_id' => 'pages#adventure'
  end

  resources :districts, :path => '/', concerns: [:menu_items, :features, :sections, :options, :page, :campaign, :legacy] do
    resources :contributors
  end


end

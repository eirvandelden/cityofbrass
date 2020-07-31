# frozen_string_literal: false

Storybuilder::Engine.routes.draw do

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
  concern :notables do
    resources :notables
    patch '/notables' => 'notables#update_list', :as => :update_notables
  end
  concern :resident_adventures_campaign do
    get '/campaign/:campaign_id' => 'resident_adventures#campaign', as: :resident_adventures_campaign
  end
  concern :stock_adventures_campaign do
    get '/campaign/:campaign_id' => 'stock_adventures#campaign', as: :stock_adventures_campaign
  end
  concern :page do
    resources :pages, concerns: [:features, :sections, :notables, :options]
    get 'pages/new/:parent_id' => 'pages#new', :as => :page_new_child
  end
  concern :legacy do
    get '/encounters', to: 'pages#index'
    get '/encounters/:id', to: 'pages#show'
    get '/handouts', to: 'pages#index'
    get '/handouts/:id', to: 'pages#show'
    get '/stories', to: 'pages#index'
    get '/stories/:id', to: 'pages#show'
  end

  scope '/resident/' do
    resources :resident_adventures, path: :adventures, concerns: [:menu_items, :features, :sections, :notables, :options, :page, :resident_adventures_campaign, :legacy]
  end

  scope '/stock/' do
    resources :stock_adventures, path: :adventures, concerns: [:menu_items, :features, :sections, :notables, :options, :page, :stock_adventures_campaign, :legacy]
  end

end

Campaignmanager::Engine.routes.draw do

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
    get '/features/new/:new_feature_type' => 'features#new_feature_type', :as => :new_feature_type
  end
  concern :sections do
    resources :sections
    patch '/sections' => 'sections#update_list', :as => :update_sections
    get '/sections/new/:new_section_type' => 'sections#new_section_type', :as => :new_section_type
  end
  concern :notables do
    get '/notables/list' => 'campaigns#notables', :as => :list
    resources :notables
    patch '/notables' => 'notables#update_list', :as => :update_notables
  end
  concern :actors do
    get '/characters' => 'campaigns#characters', :as => :characters
    resources :players
  end

  # EVEN OUR PAGES CAN BE A CONCERN
  concern :outline do
    resources :adventure_logs, controller: 'pages', type: 'AdventureLog', concerns: [:features, :sections, :notables, :options]
    get 'adventure_logs/new/:parent_id' => 'pages#new', :as => :adventure_log_new_child, type: 'AdventureLog'

    resources :game_master_notes, controller: 'pages', type: 'GameMasterNote', concerns: [:features, :sections, :notables, :options]
    get 'game_master_notes/new/:parent_id' => 'pages#new', :as => :game_master_note_new_child, type: 'GameMasterNote'

    resources :house_rules, controller: 'pages', type: 'HouseRule', concerns: [:features, :sections, :notables, :options]
    get 'house_rules/new/:parent_id' => 'pages#new', :as => :house_rule_new_child, type: 'HouseRule'
  end

  resources :campaigns, path: :campaigns, concerns: [:menu_items, :features, :sections, :notables, :options, :outline, :actors]

end

# frozen_string_literal: false

Entitybuilder::Engine.routes.draw do

  concern :sheet do
    get '/sheet', action: :sheet
  end

  concern :profile do
    get '/profile', action: :profile
  end

  concern :card do
    get '/card', action: :card
    get '/card_summary', action: :card_summary
  end

  concern :notes do
    get '/notes', action: :notes
    patch '/update_notes', action: :update_notes
  end

  concern :modifiers do
    get '/modifiers', action: :modifiers
  end

  concern :entity_core do
    get '/options', action: :options

    resources :descriptors do
      resources :modifiers
      patch '/modifiers' => 'modifiers#update_list', as: :update_modifiers
    end
    patch '/descriptors' => 'descriptors#update_list', as: :update_descriptors

    resources :ability_scores do
      resources :modifiers
      patch '/modifiers' => 'modifiers#update_list', as: :update_modifiers
    end
    patch '/ability_scores' => 'ability_scores#update_list', as: :update_ability_scores

    resources :movements do
      resources :modifiers
      patch '/modifiers' => 'modifiers#update_list', as: :update_modifiers
    end
    patch '/movements' => 'movements#update_list', as: :update_movements

    resources :class_levels do
      resources :modifiers
      patch '/modifiers' => 'modifiers#update_list', as: :update_modifiers
    end
    patch '/class_levels' => 'class_levels#update_list', as: :update_class_levels

    resources :caster_levels
    patch '/caster_levels' => 'caster_levels#update_list', as: :update_caster_levels

    resources :base_values
    patch '/base_values' => 'base_values#update_list', as: :update_base_values

    resources :skills do
      resources :modifiers
      patch '/modifiers' => 'modifiers#update_list', as: :update_modifiers
    end
    patch '/skills' => 'skills#update_list', as: :update_skills
    get '/skills/new/:skill_type' => 'skills#new_core_skill', as: :new_core_skill
    post '/skills/create/:skill_type' => 'skills#create_core_skill', as: :create_core_skill

    resources :trackables
    patch '/trackables' => 'trackables#update_list', as: :update_trackables
    get '/trackables/:id/edit_sheet' => 'trackables#edit_sheet', as: :edit_trackables_sheet
    patch '/trackables/:id/update_sheet' => 'trackables#update_sheet', as: :update_trackables_sheet
    patch '/trackables/:id/update_card' => 'trackables#update_card', as: :update_trackables_card

    resources :attacks
    patch '/attacks' => 'attacks#update_list', as: :update_attacks
    resources :defenses
    patch '/defenses' => 'defenses#update_list', as: :update_defenses
    resources :saving_throws
    patch '/saving_throws' => 'saving_throws#update_list', as: :update_saving_throws

    resources :known_spells
    patch '/known_spells/:id/use_spell' => 'known_spells#use_spell', as: :use_spell
    patch '/known_spells' => 'known_spells#update_list', as: :update_known_spells

    resources :linked_rules do
      resources :modifiers
      patch '/modifiers' => 'modifiers#update_list', as: :update_modifiers
    end
    patch '/linked_rules' => 'linked_rules#update_list', as: :update_linked_rules

    resources :inventory_items do
      resources :modifiers
      patch '/modifiers' => 'modifiers#update_list', as: :update_modifiers
    end
    patch '/inventory_items' => 'inventory_items#update_list', as: :update_inventory_items

    resources :currencies
    patch '/currencies' => 'currencies#update_list', as: :update_currencies
    get '/currencies/:id/edit_sheet' => 'currencies#edit_sheet', as: :edit_currencies_sheet
    patch '/currencies/:id/update_sheet' => 'currencies#update_sheet', as: :update_currencies_sheet
    patch '/currencies/:id/update_card' => 'currencies#update_card', as: :update_currencies_card

    resources :notables
    patch '/notables' => 'notables#update_list', :as => :update_notables

    resources :modifiers
    patch '/modifiers' => 'modifiers#update_list', as: :update_modifiers
  end

  scope '/resident/' do
    resources :resident_characters,   path: :characters, concerns: [:entity_core, :profile, :sheet, :card, :notes]
    resources :resident_creatures,    path: :creatures,  concerns: [:entity_core, :profile, :sheet, :card, :notes]
    resources :resident_npcs,         path: :npcs,       concerns: [:entity_core, :profile, :sheet, :card, :notes]
  end

  scope '/stock/' do
    resources :stock_creatures,       path: :creatures,  concerns: [:entity_core, :profile, :sheet, :card]
    resources :stock_npcs,            path: :npcs,       concerns: [:entity_core, :profile, :sheet, :card]
  end

  scope '/proprietary/' do
    resources :proprietary_creatures, path: :creatures,  concerns: [:entity_core, :profile, :sheet, :card]
    resources :proprietary_npcs,      path: :npcs,       concerns: [:entity_core, :profile, :sheet, :card]
  end

  resources :campaign_joins, only: [:destroy]
end

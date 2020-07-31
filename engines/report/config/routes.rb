# frozen_string_literal: false

Report::Engine.routes.draw do
  resources :storybuilder_snapshots, only: [:index]
  resources :campaignmanager_snapshots, only: [:index]
  resources :worldbuilder_snapshots, only: [:index]
  resources :rulebuilder_snapshots, only: [:index]
  resources :entity_snapshots, only: [:index]
  resources :gallery_snapshots, only: [:index]
  resources :resident_snapshots, only: [:index]
  resources :user_snapshots, only: [:index]
  resources :dashboards, only: [:index]
end

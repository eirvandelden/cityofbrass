# frozen_string_literal: false

Billing::Engine.routes.draw do

  resources :events

  resources :plans

  resources :subscriptions
  get 'subscriptions/:id/editsource'           => 'subscriptions#editsource', :as => :editsource_subscription
  get 'subscriptions/:id/invoices'             => 'subscriptions#invoices', :as => :subscription_invoices
  get 'subscriptions/:id/invoices/:invoice_id' => 'subscriptions#invoice', :as => :subscription_invoice

  #get  'v1/webhooks/:token/stripe' => "webhook#stripe"
  post 'v1/webhooks/:token/stripe' => "webhook#stripe"

  root :to => "subscriptions#index"

end

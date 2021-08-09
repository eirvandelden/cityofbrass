Rails.application.routes.draw do
  # require 'sidekiq/web' # used for sidekiq ui

  devise_for :admins, path_names: { sign_in: 'login', sign_out: 'logout' }
  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout' }

  get 'sso/symposium' => 'sso#symposium'

  scope "/admin" do
    resources :users
    patch '/residents/:id' => "residents#admin_update", :as => :admin_resident_update
  end

  # authenticate :admin do
  #  mount Sidekiq::Web => '/sidekiq' # used for sidekiq ui
  # end

  resources :residents

  scope '/residents' do
    get '/:resident_id/districts' => 'residents#districts', :as => :resident_districts
    get '/:resident_id/campaigns' => 'residents#campaigns', :as => :resident_campaigns
  end

  scope '/resident' do
    get '/affiliates' => 'affiliations#index', :as => :affiliates

    get '/mailboxes/inbox' => 'messages#inbox', :as => :inbox
    get '/mailboxes/sent' => 'messages#sent', :as => :sent
    get '/messages/:reply_to/reply' => 'messages#new', :as => :message_reply
    get '/messages/affiliate/:affiliate_id' => 'messages#new', :as => :message_affiliate
    resources :messages, :except => [:index]
  end

  post  '/affiliations/affiliate/:affiliate_id' => 'affiliations#create', :as => :request_affiliation
  patch '/affiliations/affiliate/:affiliate_id/:status' => 'affiliations#update', :as => :update_affiliation
  post  '/affiliations/affiliate/:affiliate_id/campaigns/:campaign_id' => 'affiliations#create_campaign', :as => :request_campaign_affiliations
  patch '/affiliations/affiliate/:affiliate_id/:status/campaigns/:campaign_id' => 'affiliations#update_campaign', :as => :update_campaign_affiliations

  mount Report::Engine,          :at => '/report'
  mount Billing::Engine,         :at => '/billing'
  mount Support::Engine,         :at => '/support'
  mount Gallery::Engine,         :at => '/gallery'
  mount Rulebuilder::Engine,     :at => '/rb'
  mount Entitybuilder::Engine,   :at => '/eb'
  mount Storybuilder::Engine,    :at => '/sb'
  mount Worldbuilder::Engine,    :at => '/wb'
  mount Campaignmanager::Engine, :at => '/cm'
  mount Activeplay::Engine,      :at => '/ap'
  mount Toolbox::Engine,         :at => '/tb'

  get 'scrolls/privacy_policy' => 'scrolls#privacy_policy'
  get 'scrolls/terms_of_service' => 'scrolls#terms_of_service'
  get 'scrolls/license' => 'scrolls#license'
  get 'scrolls/hastur' => 'scrolls#hastur'

  get '/&nbsp' => "scrolls#home"
  get '/apple-app-site-association' => "scrolls#home"
  get '/.well-known/apple-app-site-association' => "scrolls#home"
  root :to => "scrolls#home"
end

Support::Engine.routes.draw do
  
  resources :core_faqs
  resources :faqs

  root :to => 'faqs#index'
end

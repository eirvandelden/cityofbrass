Activeplay::Engine.routes.draw do

  concern :notables do
    get '/notables/list' => 'virtual_tables#notables', :as => :list
    resources :notables
    patch '/notables' => 'notables#update_list', :as => :update_notables
  end

  concern :token do
    get '/new_token' => 'virtual_tables#new_token', :as => :new_token
  end

  resources :virtual_tables, concerns: [:notables, :token]
end

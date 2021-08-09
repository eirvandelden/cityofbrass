Toolbox::Engine.routes.draw do

  resources :monsters, only: [:index]
end

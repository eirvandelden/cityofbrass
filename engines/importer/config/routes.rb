Importer::Engine.routes.draw do
  resources :previews, only: [ :new, :create, :show, :update, :destroy ]
  resources :imports, path: "/", only: [ :create, :show, :index ]
end

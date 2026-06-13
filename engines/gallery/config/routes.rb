Gallery::Engine.routes.draw do

  scope '/pkr/' do
    get 'resident'    => 'resident_images#pkr',    as: :resident_images_pkr
    get 'stock'       => 'stock_images#pkr',       as: :stock_images_pkr
    get 'admin_stock' => 'admin/stock_images#pkr', as: :admin_stock_images_pkr
    get 'map'         => 'map_images#pkr',         as: :map_images_pkr
  end

  concern :swoosh do
    get '/swoosh', action: :swoosh
  end

  scope '/resident/' do
    resources :resident_images, path: :images, concerns: [:swoosh]
  end

  scope '/stock/' do
    resources :stock_images, path: :images, concerns: [:swoosh]
  end

  namespace :admin do
    scope '/stock/' do
      resources :stock_images, path: :images, concerns: [:swoosh]
    end
  end

  scope '/map/' do
    resources :map_images, path: :images, concerns: [:swoosh]
  end

  scope '/faq/' do
    resources :faq_images, path: :images, concerns: [:swoosh]
  end

end

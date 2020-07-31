# frozen_string_literal: false

Gallery::Engine.routes.draw do

  scope '/pkr/' do
    get 'resident'    => 'resident_images#pkr',    as: :resident_images_pkr
    get 'stock'       => 'stock_images#pkr',       as: :stock_images_pkr
    get 'proprietary' => 'proprietary_images#pkr', as: :proprietary_images_pkr
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

  scope '/proprietary/' do
    resources :proprietary_images, path: :images, concerns: [:swoosh]
  end

  scope '/map/' do
    resources :map_images, path: :images, concerns: [:swoosh]
  end

  scope '/faq/' do
    resources :faq_images, path: :images, concerns: [:swoosh]
  end

end

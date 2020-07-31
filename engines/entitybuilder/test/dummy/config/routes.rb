# frozen_string_literal: false

Rails.application.routes.draw do

  mount Entitybuilder::Engine => "/entitybuilder"
end

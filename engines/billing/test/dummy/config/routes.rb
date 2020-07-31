# frozen_string_literal: false

Rails.application.routes.draw do

  mount Billing::Engine => "/billing"
end

# frozen_string_literal: false

Rails.application.routes.draw do

  mount Rulebuilder::Engine => "/rulebuilder"
end

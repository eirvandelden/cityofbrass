# frozen_string_literal: false

Rails.application.routes.draw do

  mount Gallery::Engine => "/gallery"
end

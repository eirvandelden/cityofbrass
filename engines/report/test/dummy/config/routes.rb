# frozen_string_literal: false

Rails.application.routes.draw do

  mount Report::Engine => "/report"
end

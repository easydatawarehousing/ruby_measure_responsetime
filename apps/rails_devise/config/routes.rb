Rails.application.routes.draw do

  devise_for :users

  root 'home#index'

  get '/',               to: 'home#index'
  get '/authenticated',  to: 'home#authenticated'
  get '/gc',             to: 'home#gc'
  get '/version',        to: 'home#version'
end

# frozen_string_literal: true

Rails.application.routes.draw do
  root "admin/merchants#index"

  namespace :admin do
    resources :transactions, only: %i[index show]
    resources :merchants, only: %i[index show edit update destroy]
  end

  scope module: :api do
    resources :transactions, only: %i[index show create]

    post 'auth/login', to: 'authentication#login'
    get '/*a', to: 'application#not_found'
  end
end

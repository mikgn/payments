# frozen_string_literal: true

Rails.application.routes.draw do
  root "admin/merchants#index"

  scope module: :admin do
    resources :merchants, only: %i[index show edit update destroy]
  end

  scope module: :api do
    resources :transactions, only: %i[index show create]

    post 'auth/login', to: 'authentication#login'
    get '/*a', to: 'application#not_found'
  end
end

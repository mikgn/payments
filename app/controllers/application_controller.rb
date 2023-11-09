# frozen_string_literal: true

class ApplicationController < ActionController::Base
  http_basic_authenticate_with(
    name: Rails.application.credentials.basic_authentication[:name],
    password: Rails.application.credentials.basic_authentication[:password]
  )
end

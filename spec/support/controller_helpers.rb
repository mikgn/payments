# frozen_string_literal: true

module ControllerHelpers
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  def user_login(user)
    token = JWT.encode({ user_id: user.id }, SECRET_KEY)

    request.headers['Authorization'] = "Bearer #{token}"
  end
end

# frozen_string_literal: true

module Api
  class ApplicationController < ActionController::API
    ERRORS = [
      ActiveRecord::RecordNotFound,
      JWT::DecodeError
    ].freeze

    def not_found
      render json: { error: 'not found' }
    end

    def authorize_request
      header = request.headers['Authorization']&.split(' ')&.last

      decoded = JsonWebToken.decode(header)

      @current_user = User.find(decoded[:user_id])
    rescue *ERRORS => e
      render json: { errors: e.message }, status: :unauthorized
    end

    def check_merchant_status
      render json: { error: 'inactive user' }, status: :unauthorized unless @current_user.active?
    end
  end
end

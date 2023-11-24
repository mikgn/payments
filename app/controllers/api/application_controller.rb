# frozen_string_literal: true

module Api
  class ApplicationController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    ERRORS = [
      ActiveRecord::RecordNotFound,
      JWT::DecodeError
    ].freeze

    def not_found
      respond_to do |format|
        format.json do
          render json: { error: 'not found' }, status: :not_found
        end
        format.xml do
          render xml: { error: 'Transaction not found' }, status: :not_found
        end
      end
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

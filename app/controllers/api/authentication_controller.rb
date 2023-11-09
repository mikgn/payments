# frozen_string_literal: true

module Api
  class AuthenticationController < Api::ApplicationController
    def login
      @user = User.find_by(email: login_params[:email])

      if @user&.authenticate(login_params[:password])
        token = JsonWebToken.encode(user_id: @user.id)
        time = Time.now + 24.hours.to_i

        render json: {
                 token: token,
                 exp: time.strftime('%m-%d-%Y %H:%M'),
                 email: @user.email
               },
               status: :ok
      else
        render json: { error: 'unauthorized' }, status: :unauthorized
      end
    end

    private

    def login_params
      params.require(:merchant).permit(:email, :password)
    end
  end
end

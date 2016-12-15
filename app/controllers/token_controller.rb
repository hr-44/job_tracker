class TokenController < ApplicationController
  include AuthenticationHelper

  skip_before_action :authenticate_request

  def create
    result = authenticate_user(email: params[:email], password: params[:password])

    if !result
      render('auth/errors', status: :unauthorized)
    else
      @auth_token = result
      render('auth/token', status: :ok)
    end
  end

  private

  def authenticate_user(email:, password:)
    user = User.find_by_email(email)

    if user && user.authenticate(password)
      JsonWebToken.encode(user_id: user.id)
    else
      add_auth_error!('Credentials invalid')
      nil
    end
  end
end

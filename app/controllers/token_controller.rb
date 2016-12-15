class TokenController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :handle_missing_params

  attr_reader :auth_token

  skip_before_action :authorize_request
  before_action :authenticate_user

  def create
    if !auth_token
      render('auth/errors', status: :unauthorized)
    else
      render('auth/token', status: :ok)
    end
  end

  private

  def check_params
    raise ActionController::ParameterMissing.new('email') unless params[:email].present?
    raise ActionController::ParameterMissing.new('password') unless params[:password].present?
  end

  def handle_missing_params(e)
    @errors = e
    render('shared/errors', status: :bad_request)
  end

  def authenticate_user
    check_params

    email = params[:email]
    password = params[:password]

    user = User.find_by_email(email)

    if user && user.authenticate(password)
      @auth_token = JsonWebToken.encode(user_id: user.id)
    else
      add_auth_error!('Credentials invalid')
      nil
    end
  end
end

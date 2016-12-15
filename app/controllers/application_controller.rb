class ApplicationController < ActionController::API
  # support for `helper_method`
  include AbstractController::Helpers
  # support for signed, encrypted cookies, requires `ActionDispatch::Cookies` middleware
  include ActionController::Cookies
  # support for layouts when rendering
  include ActionView::Layouts

  # TODO: re-enable this protection later on...
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # include ActionController::RequestForgeryProtection
  # protect_from_forgery with: :null_session

  include AuthorizationHelper

  attr_reader :current_user

  before_action :authorize_request

  private

  def authorize_request
    user = authorize_api_request(request.headers)

    if !user
      @current_user = nil
      render('auth/errors', status: :unauthorized)
    else
      @current_user = user
    end
  end

  def current_user?(user)
    user == current_user
  end
end

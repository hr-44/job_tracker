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

  include SessionsHelper
  include AuthenticationHelper

  helper_method :current_user, :logged_in?
  before_action :authenticate_request

  private

  def authenticate_request
    result = authorize_api_request(request.headers)

    if !result
      render('auth/errors', status: :unauthorized)
    else
      @current_user = result
    end
  end
end

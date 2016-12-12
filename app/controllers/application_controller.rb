class ApplicationController < ActionController::API
  # support for `helper_method`
  include AbstractController::Helpers
  # support for signed, encrypted cookies, requires `ActionDispatch::Cookies` middleware
  include ActionController::Cookies

  # TODO: re-enable this protection later on...
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # include ActionController::RequestForgeryProtection
  # protect_from_forgery with: :null_session

  include SessionsHelper

  helper_method :current_user, :logged_in?
end

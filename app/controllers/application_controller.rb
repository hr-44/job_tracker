class ApplicationController < ActionController::API
  include AbstractController::Helpers
  include ActionController::RequestForgeryProtection
  include ActionController::MimeResponds
  include ActionController::Cookies

  # TODO: remove all flash-related code from controllers
  include ActionController::Flash

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  include SessionsHelper

  helper_method :current_user, :logged_in?
end

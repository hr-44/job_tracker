module Sessions
  class AccountsController < BaseController
    rescue_from ActionController::ParameterMissing, with: :handle_missing_params

    before_action :set_user, only: :create

    def new
      return redirect_to(user_path) if logged_in?

      message = { text: 'Client not logged in. Go to login page.' }
      render(json: message, status: 302)
    end

    def create
      if authenticated?
        login_authenticated_user

        session[:forwarding_url] ?
          redirect_back_or(root_url) :
          render(json: { text: 'You have logged in' })
      else
        message = { text: 'Invalid email/password combination.' }
        render(json: message, status: 401)
      end
    end

    private

    def set_user
      unless params[:session].present?
        msg = "Remember to wrap up params in 'session' key"
        raise ActionController::ParameterMissing.new(msg)
      end

      @user = find_user_by_email if email_and_password?
    end

    def handle_missing_params(e)
      json = { text: e }
      render(json: json, status: :bad_request)
    end

    def email_and_password?
      email? && password?
    end

    def email?
      params[:session][:email].present?
    end

    def password?
      params[:session][:password].present?
    end

    def find_user_by_email
      email = params[:session][:email].downcase
      Users::Account.find_by(email: email)
    end

    def authenticated?
      password = params[:session][:password]
      user && user.authenticate(password)
    end

    def login_authenticated_user
      log_in(user)

      if remember_me?
        remember(user)
      else
        forget(user)
      end
    end

    def remember_me?
      remember_me = params[:session][:remember_me]
      remember_me == '1'
    end
  end
end

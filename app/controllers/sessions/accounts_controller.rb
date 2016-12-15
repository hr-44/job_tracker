module Sessions
  class AccountsController < BaseController
    rescue_from ActionController::ParameterMissing, with: :handle_missing_params

    before_action :set_user, only: :create

    def new
      return redirect_to(user_path) if logged_in?

      example_key = 'request_body_example'

      @message = {
        problem: 'Client is not authorized.',
        solution: "Login. Send a POST to '#{login_path}'. Wrap the request body params as per the example at the key, '#{example_key}'. Successful attempts receive a free cookie.",
        example_key => {
          session: {
            email: '<user_email@example.com>',
            password: '<user_password>'
          }
        }
      }

      render('sessions/login', status: 401)
    end

    def create
      if authenticated?
        login_authenticated_user
        redirect_or_show_success
      else
        @message = 'Invalid email/password combination.'
        render('sessions/login', status: 401)
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
      # TODO: send user an auth token
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

    def redirect_or_show_success
      forwarding_url = session[:forwarding_url]

      if forwarding_url.present?
        redirect_back_or(forwarding_url)
      else
        @message = 'You have logged in. Have a cookie.'
        render('sessions/login')
      end
    end
  end
end

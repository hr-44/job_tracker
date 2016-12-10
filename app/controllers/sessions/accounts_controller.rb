module Sessions
  class AccountsController < BaseController
    before_action :set_user, only: :create

    def new
      return redirect_to(user_path) if logged_in?
      # otherwise, display login page
    end

    def create
      if authenticated?
        login_authenticated_user
      else
        # TODO: send this message as part of json response
        # flash.now[:danger] = 'Invalid email/password combination'
        render 'new'
      end
    end

    private

    def set_user
      @user = find_user_by_email if email_and_password?
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
      # TODO: send this message as part of json response
      # flash[:success] = 'You are now logged in'

      if remember_me?
        remember(user)
      else
        forget(user)
      end

      redirect_back_or(root_url)
    end

    def remember_me?
      remember_me = params[:session][:remember_me]
      remember_me == '1'
    end
  end
end

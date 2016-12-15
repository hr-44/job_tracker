module StubLogin
  # @return true if a user is logged in
  def logged_in?
    !session[:user_id].nil?
  end

  def log_in_as(mocked_user, options = {})
    allow(controller).to receive(:authorize_request).and_return(true)

    if request_test?
      log_in_for_request_spec(mocked_user, options)
    else
      log_in(mocked_user)
    end
  end

  def log_out_as(mocked_user)
    if request_test?
      log_out_for_request_spec
    else
      log_out(mocked_user)
    end
    allow(controller).to receive(:current_user).and_return nil
  end

  def log_out_of_spec
    session[:user_id] = nil
  end

  private

  def request_test?
    # defined?(post_via_redirect)
    # Not doing request specs anywhere, so just return false...
    false
  end

  def log_in_for_request_spec(mocked_user, options)
    session_opts = {
      email:        (options[:email]       || mocked_user.email),
      password:     (options[:password]    || mocked_user.password),
      remember_me:  (options[:remember_me] || '1')
    }
    post(login_path, session: session_opts)
  end

  def log_in(mocked_user)
    session[:user_id] = mocked_user.id
    allow(controller).to receive(:current_user).and_return mocked_user
  end

  def log_out_for_request_spec
    delete(logout_path)
  end

  def log_out(mocked_user)
    session.delete(mocked_user.id)
    session.delete(:user_id)
  end
end

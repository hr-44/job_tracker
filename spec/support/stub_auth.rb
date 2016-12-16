module StubAuth
  def stub_auth(mocked_user)
    allow(controller).to receive(:authorize_request).and_return(true)
    allow(controller).to receive(:current_user).and_return mocked_user
  end
end

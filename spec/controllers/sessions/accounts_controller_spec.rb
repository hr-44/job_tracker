require 'rails_helper'

xdescribe Sessions::AccountsController, type: :controller do
  let(:user) { build(:user) }
  let(:account)  { build(:account) }

  describe 'GET #new' do
    context 'when user is logged in' do
      it 'redirects to current_user' do
        allow(@controller).to receive(:current_user).and_return(user)
        allow(@controller).to receive(:logged_in?).and_return(true)
        get(:new)
        expect(response).to redirect_to(user_path)
      end
    end
    context 'when user is not logged in' do
      before(:each) do
        allow(@controller).to receive(:logged_in?).and_return(false)
        get(:new)
      end

      it 'responds with 401' do
        expect(response).to have_http_status(:unauthorized)
      end
      it 'sets a value for @message' do
        expect(assigns(:message)).not_to be_nil
      end
      it 'renders "login" template' do
        expect(response).to render_template('login')
      end
    end
  end

  describe 'POST #create' do
    context 'if authenticated?' do
      before(:each) do
        allow(@controller).to receive(:set_user)
        allow(@controller).to receive(:user).and_return(user)
        allow(@controller).to receive(:authenticated?).and_return(true)
        allow(@controller).to receive(:login_authenticated_user)
      end

      it 'calls #authenticated?' do
        expect(@controller).to receive(:authenticated?)
        post(:create)
      end
      it 'calls #login_authenticted_user' do
        expect(@controller).to receive(:login_authenticated_user)
        post(:create)
      end

      context 'when there is a forwarding_url in the session' do
        it 'redirects to the forwarding_url' do
          forwarding_url = '/foo/bar'
          session[:forwarding_url] = forwarding_url
          post(:create)
          expect(response).to redirect_to(forwarding_url)
        end
      end

      context 'when there is not a forwarding_url in the session' do
        before(:each) do
          session.delete(:forwarding_url)
          post(:create)
        end

        it 'renders "login" template' do
          expect(response).to render_template('login')
        end
        it 'sets a value for @message' do
          expect(assigns(:message)).not_to be_nil
        end
      end
    end

    context 'if not authenticated' do
      before(:each) do
        allow(@controller).to receive(:set_user)
        allow(@controller).to receive(:user).and_return(user)
        allow(@controller).to receive(:authenticated?).and_return(false)
      end

      it 'returns a 401' do
        post(:create)
        expect(response).to have_http_status(:unauthorized)
      end
      it 'does not call #login_authenticated_user' do
        expect(@controller).not_to receive(:login_authenticated_user)
        post(:create)
      end
      it 'sets a value for @message' do
        post(:create)
        expect(assigns(:message)).not_to be_nil
      end
      it 'renders "login" template' do
        post(:create)
        expect(response).to render_template('login')
      end
    end
  end

  describe '#set_user' do
    good_params = {
      session: {
        email: 'foobar@example.com',
        password: 'password'
      }
    }

    context 'param checking' do
      it 'raises an error' do
        bad_params = {
          email: 'foobar@example.com',
          password: 'password'
        }
        allow(@controller).to receive(:params).and_return(bad_params)
        expect { @controller.send(:set_user) }
          .to raise_error(ActionController::ParameterMissing)
      end
      it 'does not raise an error' do
        allow(@controller).to receive(:params).and_return(good_params)
        allow(@controller).to receive(:email_and_password?).and_return(false)
        expect { @controller.send(:set_user) }.not_to raise_error
      end
    end

    context 'if email_and_password? is true' do
      before(:each) do
        allow(@controller).to receive(:email_and_password?).and_return(true)
        allow(@controller).to receive(:params).and_return(good_params)
        allow(@controller).to receive(:find_user_by_email).and_return(user)
      end

      it 'calls #find_user_by_email' do
        expect(@controller).to receive(:find_user_by_email)
        @controller.send(:set_user)
      end
      it 'sets a value for @user' do
        @controller.send(:set_user)
        actual = @controller.user
        expect(actual).not_to be_nil
      end
    end

    context 'if email_and_password? is false' do
      before(:each) do
        allow(@controller).to receive(:params).and_return(good_params)
        allow(@controller).to receive(:email_and_password?).and_return(false)
      end

      it 'does NOT call #find_user_by_email' do
        expect(@controller).not_to receive(:find_user_by_email)
        @controller.send(:set_user)
      end
      it '@user is nil' do
        @controller.send(:set_user)
        actual = @controller.user
        expect(actual).to be_nil
      end
    end
  end

  describe '#email_and_password?' do
    it 'is true if both return true' do
      allow(@controller).to receive(:email?).and_return(true)
      allow(@controller).to receive(:password?).and_return(true)
      actual = @controller.send(:email_and_password?)
      expect(actual).to be_truthy
    end
    it 'is otherwise false' do
      allow(@controller).to receive(:email?).and_return(false)
      allow(@controller).to receive(:password?).and_return(true)
      actual = @controller.send(:email_and_password?)
      expect(actual).to be_falsey
    end
  end

  describe '#email?' do
    it 'is true if a value for email is present' do
      params = { session: { email: 'foo' } }
      allow(@controller).to receive(:params).and_return(params)
      actual = @controller.send(:email?)
      expect(actual).to be_truthy
    end
    it 'is falsey if a value for email is NOT present' do
      params = { session: { email: nil } }
      allow(@controller).to receive(:params).and_return(params)
      actual = @controller.send(:email?)
      expect(actual).to be_falsey
    end
  end

  describe '#password?' do
    it 'is true if a value for password is present' do
      params = { session: { password: 'foo' } }
      allow(@controller).to receive(:params).and_return(params)
      actual = @controller.send(:password?)
      expect(actual).to be_truthy
    end
    it 'is falsey if a value for password is NOT present' do
      params = { session: { password: nil } }
      allow(@controller).to receive(:params).and_return(params)
      actual = @controller.send(:password?)
      expect(actual).to be_falsey
    end
  end

  describe '#find_user_by_email' do
    it 'calls user.find_by with a hash' do
      params = { session: { email: 'foo' } }
      allow(@controller).to receive(:params).and_return(params)
      expect(Users::Account).to receive(:find_by).with(email: 'foo')
      @controller.send(:find_user_by_email)
    end
  end

  describe '#authenticated?' do
    params = { session: { password: 'foo' } }
    before(:each) do
      allow(@controller).to receive(:params).and_return(params)
    end

    context 'when user is nil' do
      before(:each) do
        allow(@controller).to receive(:user).and_return(nil)
      end

      it 'returns false' do
        actual = @controller.send(:authenticated?)
        expect(actual).to be_nil
      end
    end

    context 'when user is authenticated' do
      before(:each) do
        allow(@controller).to receive(:user).and_return(user)
        allow(user).to receive(:authenticate).and_return(true)
      end

      it 'calls authenticate on the user' do
        expect(user).to receive(:authenticate).with('foo')
        @controller.send(:authenticated?)
      end
      it 'returns true if authentication was successful' do
        actual = @controller.send(:authenticated?)
        expect(actual).to be_truthy
      end
    end

    context 'when user is NOT authenticated' do
      before(:each) do
        allow(@controller).to receive(:user).and_return(user)
        allow(user).to receive(:authenticate).and_return(false)
      end

      it 'calls authenticate on the user' do
        expect(user).to receive(:authenticate).with('foo')
        @controller.send(:authenticated?)
      end
      it 'returns false if authentication was NOT successful' do
        actual = @controller.send(:authenticated?)
        expect(actual).to be_falsey
      end
    end
  end

  describe '#login_authenticated_user' do
    shared_examples_for 'logging in an authenticated_user' do
      before(:each) do
        allow(@controller).to receive(:user).and_return(user)
        allow(@controller).to receive(:log_in).and_return(true)
        allow(@controller).to receive(:redirect_back_or).and_return(true)
      end

      it 'calls log_in with user' do
        expect(@controller).to receive(:log_in).with(user)
        @controller.send(:login_authenticated_user)
      end
    end

    context 'when remember_me is set' do
      it_behaves_like 'logging in an authenticated_user' do
        before(:each) do
          allow(@controller).to receive(:user).and_return(user)
          allow(@controller).to receive(:remember_me?).and_return(true)
          allow(@controller).to receive(:remember).and_return(true)
        end

        it 'calls remember with user' do
          expect(@controller).to receive(:remember).with(user)
          @controller.send(:login_authenticated_user)
        end
      end
    end

    context 'when remember_me is NOT set' do
      it_behaves_like 'logging in an authenticated_user' do
        before(:each) do
          allow(@controller).to receive(:user).and_return(user)
          allow(@controller).to receive(:remember_me?).and_return(false)
          allow(@controller).to receive(:forget).and_return(true)
        end

        it 'calls forget with user' do
          expect(@controller).to receive(:forget).with(user)
          @controller.send(:login_authenticated_user)
        end
      end
    end
  end

  describe '#remember_me?' do
    it 'returns true if params[:session][:remember_me] is 1' do
      params = { session: { remember_me: '1' } }
      allow(@controller).to receive(:params).and_return(params)
      expect(@controller.send(:remember_me?)).to be_truthy
    end
    it 'otherwise returns false' do
      params = { session: { remember_me: '0' } }
      allow(@controller).to receive(:params).and_return(params)
      expect(@controller.send(:remember_me?)).to be_falsey
    end
  end
end

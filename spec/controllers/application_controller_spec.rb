require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let(:user) { build(:user) }

  # TODO: figure out cookies
  xdescribe '#current_user' do
    context 'when session has a user_id' do
      before(:each) do
        allow(@controller).to receive(:session).and_return(user_id: 1)
        allow(@controller).to receive(:find_user_with_session).and_return(:foo)
      end

      it 'calls find_user_with_session' do
        expect(@controller).to receive(:find_user_with_session)
        @controller.current_user
      end

      it 'sets @current_user variable' do
        @controller.current_user
        expect(assigns(:current_user)).to eq :foo
      end
    end

    context 'when cookie is signed' do
      before(:each) do
        cookies.signed[:user_id] = 1
      end

      context 'when user is found' do
        before(:each) do
          allow(@controller)
            .to receive(:find_user_with_signed_cookie)
            .and_return(User.new)
        end

        context 'when user is NOT authenticated' do
          before(:each) do
            allow(@controller).to receive(:authenticated_user?).and_return(false)
          end

          it 'does not call log_in' do
            expect(@controller).not_to receive(:log_in)
            @controller.current_user
          end
          it 'does not set @current_user' do
            @controller.current_user
            actual = @controller.instance_eval { @current_user }
            expect(actual).to be_nil
          end
        end

        context 'when user is authenticated' do
          before(:each) do
            allow(@controller).to receive(:authenticated_user?).and_return(true)
          end

          it 'calls logs_in' do
            expect(@controller).to receive(:log_in)
            @controller.current_user
          end
          it 'sets @current_user' do
            @controller.current_user
            actual = @controller.instance_eval { @current_user }
            expect(actual).not_to eq be_nil
          end
        end
      end

      context 'when user is NOT found' do
        before(:each) do
          allow(@controller)
            .to receive(:find_user_with_signed_cookie)
            .and_return(false)
        end

        it 'calls find_user_with_signed_cookie' do
          expect(@controller).to receive(:find_user_with_signed_cookie)
          @controller.current_user
        end
        it 'does not call authenticated_user?' do
          expect(@controller).not_to receive(:authenticated_user?)
          @controller.current_user
        end
      end
    end
  end

  describe '#current_user?' do
    it 'returns true if passed in user is same as current_user' do
      allow(@controller).to receive(:current_user).and_return('foo')
      actual = @controller.current_user?('foo')
      expect(actual).to be_truthy
    end
    it 'otherwise returns false' do
      allow(@controller).to receive(:current_user).and_return('bar')
      actual = @controller.current_user?('foo')
      expect(actual).to be_falsey
    end
  end

  describe '#log_in' do
    it 'sets session[:user_id] to user id' do
      allow(user).to receive(:id).and_return 1
      @controller.log_in(user)
      expect(session[:user_id]).to eq 1
    end
  end

  describe '#log_out' do
    before(:each) do
      allow(@controller).to receive(:forget).and_return(true)
    end

    it 'calls #forget' do
      expect(@controller).to receive(:forget)
      @controller.log_out
    end
    it 'deletes the :user_id key from session' do
      expect(session).to receive(:delete).with(:user_id)
      @controller.log_out
    end
    it 'sets the @current_user variable to nil' do
      @controller.log_out
      actual = @controller.instance_eval { @current_user }
      expect(actual).to be_nil
    end
  end

  # TODO: figure out cookies
  xdescribe '#remember' do
    before(:each) do
      allow(user).to receive(:id).and_return(1)
      allow(user).to receive(:remember_token).and_return('foo')
    end

    it 'calls remember on the user' do
      expect(user).to receive(:remember)
      @controller.remember(user)
    end
    it 'sets the user_id key of permanent signed cookie to that of user id' do
      @controller.remember(user)
      actual = cookies.permanent.signed[:user_id]
      expect(actual).to eq 1
    end
    it 'sets the remember_token key of permanent cookie to that of user id' do
      @controller.remember(user)
      actual = cookies.permanent[:remember_token]
      expect(actual).to eq 'foo'
    end
  end

  # TODO: figure out cookies
  xdescribe '#forget' do
    after(:each) do
      @controller.forget(user)
    end

    it 'calls forget on the user' do
      expect(user).to receive(:forget)
    end
    it 'deletes the :user_id key from the cookie' do
      allow(cookies).to receive(:delete).with(:remember_token)
      expect(cookies).to receive(:delete).with(:user_id)
    end
    it 'deletes the :remember_token key from the cookie' do
      allow(cookies).to receive(:delete).with(:user_id)
      expect(cookies).to receive(:delete).with(:remember_token)
    end
  end

  describe '#logged_in?' do
    it 'returns true when current_user is NOT nil' do
      allow(@controller).to receive(:current_user).and_return('foo')
      expect(@controller.logged_in?).to be_truthy
    end
    it 'returns false when current_user is nil' do
      allow(@controller).to receive(:current_user).and_return(nil)
      expect(@controller.logged_in?).to be_falsey
    end
  end

  describe '#redirect_back_or' do
    after(:each) do
      @controller.redirect_back_or('foo')
    end

    it 'deletes the :forwarding_url key from the session' do
      session[:forwarding_url] = 'foo'
      allow(@controller).to receive(:redirect_to)
      expect(session).to receive(:delete).with(:forwarding_url)
    end
    it 'calls redirect_to with the forwarding_url' do
      session[:forwarding_url] = 'foo'
      expect(@controller).to receive(:redirect_to).with(session[:forwarding_url])
    end
    it 'calls redirect_to with passed in url (default)' do
      session[:forwarding_url] = nil
      expect(@controller).to receive(:redirect_to).with('foo')
    end
  end

  describe '#store_location' do
    it 'sets session[:forwarding_url] to request.url if GET request' do
      allow(request).to receive(:get?).and_return(true)
      allow(request).to receive(:url).and_return('foo')
      @controller.store_location
      actual = session[:forwarding_url]
      expect(actual).to eq 'foo'
    end
    it 'otherwise returns nil' do
      allow(request).to receive(:get?).and_return(false)
      @controller.store_location
      actual = session[:forwarding_url]
      expect(actual).to be_nil
    end
  end

  describe '#logged_in_user' do
    it 'returns nil when already logged in' do
      allow(@controller).to receive(:logged_in?).and_return(true)
      expect(@controller.send(:logged_in_user)).to be_nil
    end

    context 'when user is not logged in' do
      before(:each) do
        allow(@controller).to receive(:logged_in?).and_return(false)
        allow(@controller).to receive(:redirect_to).and_return(true)
      end

      it 'calls #store_location' do
        expect(@controller).to receive(:store_location)
        @controller.send(:logged_in_user)
      end
      it 'calls #redirect_to' do
        expect(@controller).to receive(:redirect_to)
        @controller.send(:logged_in_user)
      end
      it 'returns false' do
        expect(@controller.send(:logged_in_user)).to be_falsey
      end
    end
  end

  describe '#find_user_with_session' do
    it 'calls User.find_by' do
      allow(@controller).to receive(:session).and_return(user_id: 1)
      expect(User).to receive(:find_by).with(id: 1)
      @controller.send(:find_user_with_session)
    end
  end

  # TODO: figure out cookies
  xdescribe '#find_user_with_signed_cookie' do
    it 'calls User.find_by' do
      allow(cookies).to receive(:signed).and_return(user_id: 1)
      expect(User).to receive(:find_by).with(id: 1)
      @controller.send(:find_user_with_signed_cookie)
    end
  end

  describe '#authenticated_user?' do
    it 'calls #authenticated? on the user' do
      cookies = { remember_token: 'foo' }
      allow(@controller).to receive(:cookies).and_return(cookies)
      expect(user).to receive(:authenticated?).with(:remember, 'foo')
      @controller.send(:authenticated_user?, user)
    end
  end
end

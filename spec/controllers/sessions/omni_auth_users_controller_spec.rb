require 'rails_helper'

describe Sessions::OmniAuthUsersController, type: :controller do
  let(:user) { build(:user) }

  describe '#POST create' do
    before(:each) do
      allow(@controller).to receive(:set_user)
      allow(@controller).to receive(:user).and_return(user)
      allow(@controller).to receive(:render).and_return(true)
    end

    context 'success' do
      before(:each) do
        allow(@controller).to receive(:log_in).and_return(true)
        post(:create, provider: 'foo')
      end

      it 'redirects to root' do
        expect(response).to redirect_to root_url
      end
    end

    context 'failed authentication' do
      before(:each) do
        allow(@controller).to receive(:log_in).and_raise('error')
      end

      it 'redirects to failure action' do
        post(:create, provider: 'foo')
        expect(response).to redirect_to(action: 'failure')
      end
      it 'returns early & does not redirect user to root url' do
        expect(@controller).not_to receive(:redirect_to).with(root_url)
        post(:create, provider: 'foo')
      end
    end
  end

  describe '#GET failure' do
    it 'redirects to root' do
      get(:failure)
      expect(response).to redirect_to(root_url)
    end
  end

  describe '#set_user' do
    context 'if #find is truthy' do
      before(:each) do
        allow(@controller).to receive(:request_auth_hash)
        allow(@controller).to receive(:find).and_return(true)
        allow(@controller).to receive(:create!)
      end

      it 'calls #request_auth_hash' do
        expect(@controller).to receive(:request_auth_hash)
        @controller.send(:request_auth_hash)
      end
      it 'calls #find' do
        expect(@controller).to receive(:find)
        @controller.send(:set_user)
      end
      it 'does NOT call #create!' do
        expect(@controller).not_to receive(:create!)
        @controller.send(:set_user)
      end
      it 'sets a value for @user' do
        @controller.send(:set_user)
        actual = @controller.user
        expect(actual).not_to be_nil
      end
    end

    context 'if #find is falsey' do
      before(:each) do
        allow(@controller).to receive(:request_auth_hash)
        allow(@controller).to receive(:find).and_return(nil)
        allow(@controller).to receive(:create!).and_return(:foo)
      end

      it 'calls #request_auth_hash' do
        expect(@controller).to receive(:request_auth_hash)
        @controller.send(:request_auth_hash)
      end
      it 'calls #find' do
        expect(@controller).to receive(:find)
        @controller.send(:set_user)
      end
      it 'calls #create!' do
        expect(@controller).to receive(:create!)
        @controller.send(:set_user)
      end
      it 'sets a value for @user' do
        @controller.send(:set_user)
        actual = @controller.user
        expect(actual).not_to be_nil
      end
    end

    context 'if calls to both methods return falsey values' do
      before(:each) do
        allow(@controller).to receive(:request_auth_hash)
        allow(@controller).to receive(:find).and_return(nil)
        allow(@controller).to receive(:create!).and_return(nil)
      end

      it 'calls #request_auth_hash' do
        expect(@controller).to receive(:request_auth_hash)
        @controller.send(:request_auth_hash)
      end
      it 'calls #find' do
        expect(@controller).to receive(:find)
        @controller.send(:set_user)
      end
      it 'calls #create!' do
        expect(@controller).to receive(:create!)
        @controller.send(:set_user)
      end
      it '@user is nil' do
        @controller.send(:set_user)
        actual = @controller.user
        expect(actual).to be_nil
      end
    end
  end

  describe '#request_auth_hash' do
    let(:env) do
      { 'omniauth.auth' => 'foobar' }
    end
    let(:request) do
      double('request', env: env)
    end

    before(:each) do
      allow(@controller).to receive(:request).and_return(request)
    end

    it 'calls #request' do
      expect(@controller).to receive(:request)
      @controller.send(:request_auth_hash)
    end
    it 'calls #env on request' do
      expect(request).to receive(:env)
      @controller.send(:request_auth_hash)
    end
    it 'returns value of the "omni_auth.auth" key' do
      actual = @controller.send(:request_auth_hash)
      expect(actual).to eq 'foobar'
    end
    it 'sets the @auth_hash ivar' do
      expect { @controller.send(:request_auth_hash) }
        .to change {@controller.auth_hash }
        .from(nil).to('foobar')
    end
  end

  describe '#find' do
    before(:each) do
      allow(@controller).to receive(:auth_hash).and_return(:foo)
      allow(Users::OmniAuthUser).to receive(:find_from_omni_auth)
    end
    after(:each) do
      @controller.send(:find)
    end

    it 'calls #auth_hash' do
      expect(@controller).to receive(:auth_hash)
    end
    it 'calls .find_from_omni_auth on Users::OmniAuthUser' do
      expect(Users::OmniAuthUser).to receive(:find_from_omni_auth).with(:foo)
    end
  end

  describe '#create!' do
    before(:each) do
      allow(@controller).to receive(:auth_hash).and_return(:foo)
      allow(Users::OmniAuthUser).to receive(:create_from_omni_auth!)
    end
    after(:each) do
      @controller.send(:create!)
    end

    it 'calls #auth_hash' do
      expect(@controller).to receive(:auth_hash)
    end
    it 'calls .create_from_omni_auth! on Users::OmniAuthUser' do
      expect(Users::OmniAuthUser)
        .to receive(:create_from_omni_auth!)
        .with(:foo)
    end
  end
end

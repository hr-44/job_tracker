require 'rails_helper'

describe ApplicationController, type: :controller do
  let(:user) { build(:user) }

  describe '#authorize_request' do
    controller do
      def index; end
    end

    context 'authorized user' do
      before(:each) do
        allow(controller).to receive(:authorize_api_request).and_return(user)
        get(:index)
      end

      it 'does not render auth/errors' do
        expect(response).not_to render_template('auth/errors')
      end
      it 'sets value for @current_user' do
        expect(assigns(:current_user)).to eq(user)
      end
    end

    context 'unauthorized user' do
      before(:each) do
        allow(controller).to receive(:authorize_api_request).and_return(nil)
        controller.instance_eval { @current_user = 'current user' }
        get(:index)
      end

      it 'renders auth/errors' do
        expect(response).to render_template('auth/errors')
      end
      it 'responds with a 401' do
        expect(response).to have_http_status(:unauthorized)
      end
      it 'sets @current_user to nil' do
        expect(assigns(:current_user)).to be_nil
      end
    end
  end

  describe '#current_user?' do
    it 'returns true if passed in user is same as current_user' do
      allow(controller).to receive(:current_user).and_return('foo')
      actual = controller.send(:current_user?, 'foo')
      expect(actual).to be_truthy
    end
    it 'otherwise returns false' do
      allow(controller).to receive(:current_user).and_return('bar')
      actual = controller.send(:current_user?, 'foo')
      expect(actual).to be_falsey
    end
  end

  describe 'AuthorizationHelper' do
    let(:good_headers) { { 'Authorization' => 'Basic deadbeef' } }
    let(:bad_headers)  { { 'foo' => 'bar' } }

    describe '#authorize_api_request' do
      context 'when token is decoded' do
        before(:each) do
          allow(controller).to receive(:decode_auth_token).with(good_headers).and_return('ok')
        end

        shared_examples_for 'expected method calls for #authorize_api_request' do
          after(:each) do
            controller.send(:authorize_api_request, good_headers)
          end

          it 'calls #decode_auth_token' do
            expect(controller).to receive(:decode_auth_token)
          end
          it 'calls #find_user_from_token' do
            expect(controller).to receive(:find_user_from_token)
          end
        end

        context 'when user is found' do
          before(:each) do
            allow(controller).to receive(:find_user_from_token).and_return(user)
          end

          it_behaves_like 'expected method calls for #authorize_api_request'

          it 'returns the user' do
            actual = controller.send(:authorize_api_request, good_headers)
            expect(actual).to eq(user)
          end
          it 'does not add any @auth_errors' do
            controller.send(:authorize_api_request, good_headers)
            expect(assigns(:auth_errors)).to be_nil
          end
        end

        context 'when user is not found' do
          before(:each) do
            allow(controller).to receive(:find_user_from_token).and_return(nil)
          end

          it_behaves_like 'expected method calls for #authorize_api_request'

          it 'returns nil' do
            actual = controller.send(:authorize_api_request, good_headers)
            expect(actual).to be_nil
          end
          it 'adds errors to @auth_errors' do
            controller.send(:authorize_api_request, good_headers)
            expect(assigns(:auth_errors)).not_to be_nil
          end
        end
      end

      context 'when token is not decoded' do
        before(:each) do
          allow(controller).to receive(:decode_auth_token).with(bad_headers).and_return(nil)
        end

        it 'adds a value to @auth_errors' do
          controller.send(:authorize_api_request, bad_headers)
          expect(assigns(:auth_errors)).not_to be_nil
        end
        it 'returns nil' do
          actual = controller.send(:authorize_api_request, bad_headers)
          expect(actual).to be_nil
        end
      end
    end

    describe '#decode_auth_token' do
      shared_examples_for 'expected method calls for #decode_auth_token' do
        it 'calls #http_auth_header' do
          expect(controller).to receive(:http_auth_header)
        end
        it 'calls .decode on JsonWebToken' do
          expect(JsonWebToken).to receive(:decode)
        end
      end

      context 'with good headers' do
        before(:each) do
          allow(controller).to receive(:http_auth_header).with(:good_headers).and_return('ok')
          allow(JsonWebToken).to receive(:decode).with('ok').and_return('decoded token')
        end

        after(:each) do
          controller.send(:decode_auth_token, :good_headers)
        end

        it_behaves_like 'expected method calls for #decode_auth_token'

        it 'returns a decoded token' do
          actual = controller.send(:decode_auth_token, :good_headers)
          expect(actual).to eq 'decoded token'
        end
      end

      context 'with bad headers'  do
        before(:each) do
          allow(controller).to receive(:http_auth_header).with(:bad_headers).and_return(nil)
          allow(JsonWebToken).to receive(:decode).with(nil).and_return(nil)
        end

        after(:each) do
          controller.send(:decode_auth_token, :bad_headers)
        end

        it_behaves_like 'expected method calls for #decode_auth_token'

        it 'returns something falsey' do
          actual = controller.send(:decode_auth_token, :bad_headers)
          expect(actual).to be_falsey
        end
      end
    end

    describe '#http_auth_header' do
      context 'when Authorization header is present' do
        it 'returns an encoded token' do
          actual = controller.send(:http_auth_header, good_headers)
          expect(actual).to eq 'deadbeef'
        end
      end

      context 'when Authorization header is not present' do
        it 'adds value to @auth_errors' do
          controller.send(:http_auth_header, bad_headers)
          expect(assigns(:auth_errors)).not_to be_nil
        end
        it 'returns nil' do
          actual = controller.send(:http_auth_header, bad_headers)
          expect(actual).to be_nil
        end
      end
    end

    describe '#find_user_from_token' do
      before(:each) do
        allow(user).to receive(:id).and_return(1)
        allow(User).to receive(:find).with(1).and_return(user)
        allow(User).to receive(:find).with(2).and_return(nil)
      end

      context 'when user is found' do
        let(:token) { { user_id: 1 } }

        it 'calls .find on User' do
          expect(User).to receive(:find).with(1)
          controller.send(:find_user_from_token, token)
        end

        it 'returns the user with matching id' do
          actual = controller.send(:find_user_from_token, token)
          expect(actual).to eq(user)
          expect(actual.id).to be(1)
        end
      end

      context 'when user is not found' do
        let(:token) { { user_id: 2 } }

        it 'calls .find on User' do
          expect(User).to receive(:find).with(2)
          controller.send(:find_user_from_token, token)
        end

        it 'returns nil' do
          actual = controller.send(:find_user_from_token, token)
          expect(actual).to be_nil
        end
      end
    end

    describe '#add_auth_error!' do
      let(:message) { 'bar' }

      context 'when @auth_errors is nil' do
        before(:each) do
          controller.instance_eval { @auth_errors = nil }
        end

        it 'sets @auth_errors to an array' do
          expect{ controller.send(:add_auth_error!, message) }
            .to change { assigns(:auth_errors) }.from(nil).to([message])
        end
      end

      context 'when @auth_errors already present' do
        before(:each) do
          controller.instance_eval { @auth_errors = ['foo'] }
        end

        it 'adds a message to @auth_errors' do
          expect{ controller.send(:add_auth_error!, message) }
            .to change { assigns(:auth_errors) }
            .from(['foo']).to(['foo', message])
        end
      end
    end
  end
end

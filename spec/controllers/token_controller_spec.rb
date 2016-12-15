require 'rails_helper'

describe TokenController, type: :controller do
  let(:user) { build(:user) }

  describe 'POST #create' do
    context 'with an authenticated user' do
      before(:each) do
        allow(controller).to receive(:authenticate_user)
        allow(controller).to receive(:auth_token).and_return(true)
        post(:create, params: { email: 'e', password: 'p' })
      end

      it 'renders auth/token' do
        expect(response).to render_template('auth/token')
      end
      it 'responds with a 200' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with an unauthenticated user' do
      before(:each) do
        allow(controller).to receive(:authenticate_user).and_return(false)
        post(:create, params: { email: 'e', password: 'p' })
      end

      it 'renders auth/errors' do
        expect(response).to render_template('auth/errors')
      end
      it 'responds with a 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'parameter checking' do
      shared_examples_for 'handles bad params' do
        before(:each) do
          post(:create, params: bad_params)
        end

        it 'responds with 400' do
          expect(response).to have_http_status(:bad_request)
        end
        it 'renders shared/errors' do
          expect(response).to render_template('shared/errors')
        end
        it 'sets value for @errors' do
          expect(assigns(:errors)).not_to be_nil
        end

        context 'missing password' do
          it_behaves_like 'handles bad params' do
            let!(:bad_params) { { email: 'email' } }
          end
        end

        context 'missing email' do
          it_behaves_like 'handles bad params' do
            let!(:bad_params) { { password: 'password' } }
          end
        end
      end
    end
  end

  describe '#check_params' do
    it 'raises ActionController::ParameterMissing when missing password' do
      params = { email: 'email' }
      allow(controller).to receive(:params).and_return(params)
      expect { controller.send(:check_params) }
        .to raise_error(ActionController::ParameterMissing)
    end

    it 'raises ActionController::ParameterMissing when missing email' do
      params = { password: 'password' }
      allow(controller).to receive(:params).and_return(params)
      expect { controller.send(:check_params) }
        .to raise_error(ActionController::ParameterMissing)
    end

    it 'does not raise an error' do
      params = { email: 'email', password: 'password' }
      allow(controller).to receive(:params).and_return(params)
      expect { controller.send(:check_params) }
        .not_to raise_error
    end
  end

  describe '#authenticate_user' do
    context 'success' do
      let(:good_params) { { email: 'foo@bar.com', password: 'foobar' } }

      before(:each) do
        allow(controller).to receive(:params).and_return(good_params)
        allow(User).to receive(:find_by_email).and_return(user)
        allow(user).to receive(:authenticate).and_return(true)
        allow(user).to receive(:id).and_return(1)
        allow(JsonWebToken).to receive(:encode).and_return('jwt')
      end
      after(:each) do
        controller.send(:authenticate_user)
      end

      it 'calls .find_by_email on User' do
        expect(User).to receive(:find_by_email).with(good_params[:email])
      end
      it 'calls #authenticate on user' do
        expect(user).to receive(:authenticate).with(good_params[:password])
      end
      it 'calls .encode on JsonWebToken' do
        expect(JsonWebToken).to receive(:encode).with(user_id: 1)
      end
      it 'returns an authentication token' do
        actual = controller.send(:authenticate_user)
        expect(actual).to eq 'jwt'
      end
      it 'sets a value for @auth_token' do
        controller.send(:authenticate_user)
        expect(assigns(:auth_token)).not_to be_nil
      end
    end

    context 'bad password or email' do
      let(:bad_params) { { email: 'foo@bar.com', password: 'bad' } }

      before(:each) do
        allow(controller).to receive(:params).and_return(bad_params)
        allow(User).to receive(:find_by_email).and_return(user)
        allow(user).to receive(:authenticate).and_return(false)
      end
      after(:each) do
        controller.send(:authenticate_user)
      end

      it 'calls .find_by_email on User' do
        expect(User).to receive(:find_by_email).with(bad_params[:email])
      end
      it 'calls #authenticate on user' do
        expect(user).to receive(:authenticate).with(bad_params[:password])
      end
      it 'sets value for @auth_error' do
        controller.send(:authenticate_user)
        expect(assigns(:auth_errors)).not_to be_nil
      end
      it 'does not set a value for @auth_token' do
        controller.send(:authenticate_user)
        expect(assigns(:auth_token)).to be_nil
      end
      it 'returns nil' do
        actual = controller.send(:authenticate_user)
        expect(actual).to be_nil
      end
    end
  end
end

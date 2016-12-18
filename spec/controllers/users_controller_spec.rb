require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { build(:user) }

  before(:each) { log_in_as(user) }

  describe 'GET #show' do
    before(:each) do
      allow(User).to receive(:find).and_return(user)
      allow(User).to receive(:filter_user_info).and_return(true)
      get(:show)
    end

    it 'assigns user as @user' do
      expect(assigns(:user)).to eq(user)
    end
    it 'sets a value for @filtered_user_info' do
      expect(assigns(:filtered_user_info)).not_to be_nil
    end
    it 'renders show' do
      expect(response).to render_template('show')
    end
  end

  describe 'POST #create' do
    let(:attr_for_create) do
      {
        name: 'Foo Bar',
        email: 'foo@example.com',
        password: 'foobar'
      }
    end

    shared_examples_for 'calls these methods every time' do
      after(:each) do
        post(:create, params: { users_account: attr_for_create })
      end

      it 'calls #new_account' do
        expect(controller).to receive(:new_account)
      end
      it 'calls #user_params' do
        expect(controller).to receive(:user_params)
      end
    end

    before(:each) do
      allow(controller).to receive(:new_account).and_return(user)
    end

    context 'with valid params' do
      before(:each) do
        allow(user).to receive(:save).and_return(true)
        allow(User).to receive(:filter_user_info).and_return(true)
      end

      it_behaves_like 'calls these methods every time'

      context 'functional tests' do
        before(:each) do
          post(:create, params: { users_account: attr_for_create })
        end

        it 'sets @user to a new User' do
          expect(assigns(:user)).to be_a(User)
        end
        it 'sets a value for @filtered_user_info' do
          expect(assigns(:filtered_user_info)).not_to be_nil
        end
        it 'sets a value for @message' do
          expect(assigns(:message)).not_to be_nil
        end
        it 'renders success' do
          expect(response).to render_template('success')
        end
        it 'returns a 201' do
          expect(response).to have_http_status(:created)
        end
      end

      context 'expected method calls' do
        after(:each) do
          post(:create, params: { users_account: attr_for_create })
        end

        it 'calls filtered_user_info' do
          expect(controller).to receive(:filter_user_info)
        end
        it 'calls log_in' do
          expect(controller).to receive(:log_in)
        end
      end
    end

    context 'with invalid params' do
      before(:each) do
        allow(user).to receive(:save).and_return(false)
        post(:create, params: { users_account: attr_for_create })
      end

      it_behaves_like 'calls these methods every time'

      it 'sets a value for @errors' do
        expect(assigns(:errors)).not_to be_nil
      end
      it 'responds with unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    let(:attr_for_update) do
      { users_account: { email: 'bar@example.com' } }
    end

    before(:each) do
      allow(User).to receive(:find).and_return(user)
    end

    context 'with valid params' do
      before(:each) do
        allow(user).to receive(:update).and_return(true)
        allow(User).to receive(:filter_user_info).and_return(true)
      end

      context 'functional tests' do
        before(:each) do
          put(:update, params: attr_for_update)
        end

        it 'assigns the requested user as @user' do
          expect(assigns(:user)).to eq(user)
        end
        it 'sets a value for @filtered_user_info' do
          expect(assigns(:filtered_user_info)).not_to be_nil
        end
        it 'sets a value for @message' do
          expect(assigns(:message)).not_to be_nil
        end
        it 'renders success' do
          expect(response).to render_template('success')
        end
        it 'returns a 200' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'expected method calls' do
        after(:each) do
          put(:update, params: attr_for_update)
        end

        it 'calls filtered_user_info' do
          expect(controller).to receive(:filter_user_info)
        end
        it 'updates the requested user' do
          expect(user).to receive(:update)
        end
      end
    end

    context 'with invalid params' do
      before(:each) do
        allow(user).to receive(:update).and_return(false)
        put(:update, params: attr_for_update)
      end

      it 'assigns the user as @user' do
        expect(assigns(:user)).to eq(user)
      end
      it 'sets a value for @errors' do
        expect(assigns(:errors)).not_to be_nil
      end
      it 'responds with unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      allow(User).to receive(:find).and_return(user)
      allow(user).to receive(:destroy).and_return(true)
    end

    it 'calls destroy on user' do
      expect(user).to receive(:destroy)
      delete(:destroy, params: { id: 'foo' })
    end
    it 'sets a value for @message' do
      delete(:destroy, params: { id: 'foo' })
      expect(assigns(:message)).not_to be_nil
    end
    it 'renders "shared/destroy"' do
      delete(:destroy, params: { id: 'foo' })
      expect(response).to render_template('shared/destroy')
    end
  end

  describe '#set_user' do
    before(:each) do
      allow(controller).to receive(:current_user).and_return(user)
      allow(user).to receive(:id).and_return(1)
      allow(User).to receive(:find).and_return(user)
    end

    it 'calls #current_user' do
      expect(controller).to receive(:current_user)
      controller.send(:set_user)
    end
    it 'calls #id on the current_user' do
      expect(user).to receive(:id)
      controller.send(:set_user)
    end
    it 'calls #find on User' do
      expect(User).to receive(:find).with(1)
      controller.send(:set_user)
    end
    it 'sets a value for @user' do
      expect { controller.send(:set_user) }
        .to change { assigns(:user) }
        .from(nil).to(user)
    end
  end

  describe '#new_account' do
    before(:each) do
      allow(Users::Account).to receive(:new)
    end

    it 'calls .new on Users::Account with an empty hash' do
      expect(Users::Account).to receive(:new).with({})
      controller.send(:new_account)
    end
    it 'calls .new on Users::Account with some params' do
      mock_params = { foo: 'bar' }
      expect(Users::Account).to receive(:new).with(mock_params)
      controller.send(:new_account, mock_params)
    end
  end

  describe '#check_user' do
    it 'calls #current_user?' do
      allow(controller).to receive(:current_user?).and_return(true)
      expect(controller).to receive(:current_user?).with(assigns(:user))
      controller.send(:check_user)
    end

    context 'when #correct_user? is true' do
      it 'does not redirect' do
        allow(controller).to receive(:current_user?).and_return(true)
        expect(controller).not_to receive(:redirect_to)
        controller.send(:check_user)
      end
    end

    context 'when #current_user? is false' do
      before(:each) do
        allow(controller).to receive(:current_user?).and_return(false)
        allow(controller).to receive(:render).and_return(true)
      end

      it 'renders shared/errors' do
        expect(controller).to receive(:render).with('shared/errors', status: :unauthorized)
        controller.send(:check_user)
      end
      it 'sets value for @errors' do
        controller.send(:check_user)
        expect(assigns(:errors)).not_to be_nil
      end
    end
  end

  describe '#filter_user_info' do
    before(:each) do
      allow(controller).to receive(:user).and_return(user)
      allow(User).to receive(:filter_user_info).and_return('filtered_user_info')
    end

    it 'calls User.filter_user_info with the current user' do
      expect(User).to receive(:filter_user_info).with(controller.user)
      controller.send(:filter_user_info)
    end
    it 'sets a value for @filtered_user_info' do
      expect { controller.send(:filter_user_info) }
        .to change {controller.filtered_user_info}
        .from(nil)
        .to('filtered_user_info')
    end
  end
end

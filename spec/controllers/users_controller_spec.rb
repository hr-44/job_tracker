require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { build(:user) }

  before(:each) { log_in_as(user) }

  describe 'GET #show' do
    it 'assigns the requested user as @user' do
      allow(User).to receive(:find).and_return(user)
      get(:show, id: user.id)
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'GET #new' do
    it 'assigns a new user as @user' do
      get(:new)
      expect(assigns(:user)).to be_a_new(User)
    end
    xit 'renders the "new" template' do
      get(:new)
      expect(response).to render_template 'new'
    end
    it 'calls #new_account' do
      allow(controller).to receive(:new_account)
      expect(controller).to receive(:new_account).with(no_args)
      controller.new
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested user as @user' do
      allow(User).to receive(:find).and_return(user)
      get(:edit, id: user.id)
      expect(assigns(:user)).to eq(user)
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
        post(:create, users_account: attr_for_create)
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
      end

      it_behaves_like 'calls these methods every time'

      it 'sets @user to a new User' do
        post(:create, users_account: attr_for_create)
        expect(assigns(:user)).to be_a(User)
      end
      it 'calls log_in' do
        expect(controller).to receive(:log_in)
        post(:create, users_account: attr_for_create)
      end
      it 'redirects to the created user' do
        post(:create, users_account: attr_for_create)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with invalid params' do
      before(:each) do
        allow(user).to receive(:save).and_return(false)
        post(:create, users_account: attr_for_create)
      end

      it_behaves_like 'calls these methods every time'

      xit 're-renders the "new" template' do
        expect(response).to render_template('new')
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
      end

      it 'updates the requested user' do
        expect(user).to receive(:update)
        put(:update, attr_for_update)
      end

      it 'assigns the requested user as @user' do
        put(:update, attr_for_update)
        expect(assigns(:user)).to eq(user)
      end

      it 'redirects to the user' do
        put(:update, attr_for_update)
        expect(response).to redirect_to(user_url)
      end
    end

    context 'with invalid params' do
      before(:each) do
        allow(user).to receive(:update).and_return(false)
        put(:update, attr_for_update)
      end

      it 'assigns the user as @user' do
        expect(assigns(:user)).to eq(user)
      end

      xit 're-renders the "edit" template' do
        expect(response).to render_template('edit')
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
      delete(:destroy, id: 'foo')
    end
    it 'redirects to the users list' do
      delete(:destroy, id: 'foo')
      expect(response).to redirect_to(user_url)
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
    after(:each) do
      controller.send(:check_user)
    end

    it 'calls #current_user?' do
      allow(controller).to receive(:current_user?).and_return(true)
      expect(controller).to receive(:current_user?).with(assigns(:user))
    end
    context 'when #correct_user? is true' do
      it 'does not redirect' do
        allow(controller).to receive(:current_user?).and_return(true)
        expect(controller).not_to receive(:redirect_to)
      end
    end
    context 'when #correct_user? is false' do
      it 'redirects to root_url' do
        allow(controller).to receive(:current_user?).and_return(false)
        allow(controller).to receive(:redirect_to).and_return(true)
        expect(controller).to receive(:redirect_to).with(root_url)
      end
    end
  end
end

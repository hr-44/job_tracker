require 'rails_helper'

RSpec.describe ContactsController, type: :controller do
  let(:user) { build(:user, id: 1) }
  let(:contact) { build(:contact) }
  let(:company) { build(:company) }

  before(:each) { log_in_as(user) }

  describe 'GET #index' do
    let!(:relation) do
      ActiveRecord::Relation.new(Contact, 'contacts', {})
    end

    before(:each) do
      allow(controller)
        .to receive(:collection_belonging_to_user)
        .and_return(relation)
      allow(relation).to receive(:sorted).and_return(relation)
      allow(controller).to receive(:custom_index_sort).and_return([contact])
    end

    describe 'functional tests' do
      before(:each) do
        get(:index, params: { sort: true })
      end

      it 'returns a 200' do
        expect(response).to have_http_status(200)
      end
      it 'assigns a value to @contacts' do
        expect(assigns(:contacts)).not_to be_nil
      end
      it 'sends JSON' do
        expect(response.content_type).to eq('application/json')
      end
      it 'renders index' do
        expect(response).to render_template('index')
      end
    end

    describe 'expected method calls' do
      after(:each) do
        get(:index, params: { sort: true })
      end

      it 'calls #collection_belonging_to_user' do
        expect(controller).to receive(:collection_belonging_to_user)
      end
      it 'calls #sorted on the relation' do
        expect(relation).to receive(:sorted)
      end
      it 'calls #custom_index_sort' do
        expect(controller).to receive(:custom_index_sort)
      end
    end
  end

  describe 'GET #show' do
    before(:each) do
      stub_before_actions
      get(:show, params: { id: 'joe-schmoe' })
    end

    it 'returns a 200' do
      expect(response).to have_http_status(200)
    end
    it 'renders show' do
      expect(response).to render_template('show')
    end

    context '@notable, @notes, @note' do
      it 'assigns @contact to @notable' do
        expect(assigns(:notable)).to eq(contact)
      end
      it 'calls #notes on @notable' do
        expect(assigns(:notable)).to receive(:notes)
        get(:show, params: { id: 'joe-schmoe' })
      end
      it 'assigns @notes to @notable.notes' do
        expected = Note::ActiveRecord_Associations_CollectionProxy
        expect(assigns(:notes)).to be_instance_of(expected)
      end
      it 'assigns @note to a new instance of Note' do
        expect(assigns(:note)).to be_a_new Note
      end
    end
  end

  describe 'POST #create' do
    let(:attr_for_create) do
      {
        first_name: 'Foo',
        last_name: 'Bar',
        title: '_title',
        company_name: company.name
      }
    end

    before(:each) do
      allow(controller)
        .to receive(:contact_params_with_associated_ids)
        .and_return(attr_for_create)
      allow(Contact).to receive(:new).and_return(contact)
    end

    describe '@contact' do
      before(:each) do
        allow(controller).to receive(:save_and_respond).and_return(true)
        allow(controller).to receive(:render).and_return(true)
      end
      after(:each) do
        post(:create, params: { contact: attr_for_create })
      end

      it 'calls #contact_params_with_associated_ids' do
        expect(controller).to receive(:contact_params_with_associated_ids)
      end
      it 'calls Contact.new' do
        expect(Contact).to receive(:new).with(attr_for_create)
      end
    end

    context 'with valid params' do
      before(:each) do
        allow(contact).to receive(:save).and_return(true)
        post(:create, params: { contact: attr_for_create })
      end

      it 'assigns a newly created contact to @contact' do
        expect(assigns(:contact)).to be_a_new(Contact)
      end
      it 'returns HTTP success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'with invalid params' do
      before(:each) do
        allow(contact).to receive(:save).and_return(false)
        post(:create, params: { contact: attr_for_create })
      end

      it 'assigns a newly created contact to @contact' do
        expect(assigns(:contact)).to be_a_new(Contact)
      end
      it 'returns HTTP code' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    let(:attr_for_update) do
      {
        id: 'foo-bar',
        contact: {
          first_name: 'Bar',
          last_name: 'foo'
        }
      }
    end

    before(:each) do
      allow(controller)
        .to receive(:contact_params_with_associated_ids)
        .and_return(attr_for_update)
      stub_before_actions
    end

    context 'with valid params' do
      before(:each) do
        allow(contact).to receive(:update).and_return(true)
      end

      it 'calls #contact_params_with_associated_ids' do
        expect(controller).to receive(:contact_params_with_associated_ids)
        put(:update, params: attr_for_update)
      end
      it 'calls #update on the requested contact' do
        expect(contact).to receive(:update).with(attr_for_update)
        put(:update, params: attr_for_update)
      end
      it 'assigns the requested contact as @contact' do
        put(:update, params: attr_for_update)
        expect(assigns(:contact)).to eq(contact)
      end
      it 'renders show' do
        put(:update, params: attr_for_update)
        expect(response).to render_template('show')
      end
    end

    context 'with invalid params' do
      before(:each) do
        allow(contact).to receive(:update).and_return(false)
      end

      it 'calls #contact_params_with_associated_ids' do
        expect(controller).to receive(:contact_params_with_associated_ids)
        put(:update, params: attr_for_update)
      end
      it 'assigns the contact as @contact' do
        put(:update, params: attr_for_update)
        expect(assigns(:contact)).to eq(contact)
      end
      it 'sends HTTP failure' do
        put(:update, params: attr_for_update)
        expect(response.status).to be >= 400
        expect(response.status).to be < 500
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      allow(contact).to receive(:destroy).and_return(true)
      stub_before_actions
    end

    it 'calls destroy on the requested contact' do
      expect(contact).to receive(:destroy)
      delete(:destroy, params: { id: 'joe-schmoe' })
    end
    it 'sends back a JSON message' do
      delete(:destroy, params: { id: 'joe-schmoe' })
      expect(response.content_type).to eq('application/json')
    end
  end

  describe '#set_contact' do
    let(:params)   { { id: 1 } }
    let(:relation) { double('Contact::ActiveRecord_Relation') }

    before(:each) do
      allow(controller).to receive(:params).and_return(params)
      allow(controller).to receive(:current_user).and_return(user)
      allow(user).to receive(:id).and_return(1)
      allow(Contact).to receive(:belonging_to_user).and_return(relation)
      allow(relation).to receive(:friendly).and_return(relation)
      allow(relation).to receive(:find).and_return(relation)
    end
    after(:each) do
      controller.send(:set_contact)
    end

    it 'calls #belonging_to_user on Contact' do
      expect(Contact).to receive(:belonging_to_user).with(user.id)
    end
    it 'calls #friendly.find' do
      expect(relation).to receive(:friendly)
      expect(relation).to receive(:find)
    end
  end

  # TODO: This method is much different than before. Rewrite tests
  xdescribe '#contact_params_with_associated_ids' do
    let(:contact_params) { { foo: 'bar' } }

    before(:each) do
      allow(controller).to receive(:set_company_id).and_return(1)
      allow(controller).to receive(:current_user).and_return(user)
      allow(user).to receive(:id).and_return(1)
      allow(controller).to receive(:contact_params).and_return(contact_params)
    end
    after(:each) do
      controller.send(:contact_params_with_associated_ids)
    end

    it 'calls #set_company_id' do
      expect(controller).to receive(:set_company_id)
    end
    it 'calls #current_user' do
      expect(controller).to receive(:current_user)
    end
    it 'calls #id on current_user' do
      expect(user).to receive(:id)
    end
    it 'calls #contact_params' do
      expect(controller).to receive(:contact_params)
    end
    it 'calls #merge on contact_params' do
      expected_args = { company_id: 1, user_id: 1 }
      expect(contact_params).to receive(:merge).with(expected_args)
    end
  end

  describe '#set_company_id' do
    let(:params) do
      { contact: { company_name: 'foo' } }
    end

    before(:each) do
      allow(controller).to receive(:params).and_return(params)
      allow(Company).to receive(:get_record_val_by)
    end

    it 'calls .get_record_val_by on Company' do
      expect(Company).to receive(:get_record_val_by).with(:name, 'foo')
      controller.send(:set_company_id)
    end
  end

  private

  def stub_before_actions
    allow(controller).to receive(:set_contact)
    allow(controller).to receive(:check_user)
    allow(controller).to receive(:contact).and_return(contact)
    controller.instance_eval { @contact = contact }
  end
end

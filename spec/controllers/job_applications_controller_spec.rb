require 'rails_helper'

RSpec.describe JobApplicationsController, type: :controller do
  let(:user) { build(:user, id: 1) }
  let(:job_application) { build(:job_application) }
  let(:company) { build(:company) }
  let(:posting) { build(:posting) }
  let(:cover_letter) { build(:cover_letter) }

  before(:each) { log_in_as(user) }

  describe 'GET #index' do
    let(:relation) do
      ActiveRecord::Relation.new(JobApplication, 'job_applications', {})
    end

    before(:each) do
      allow(controller)
        .to receive(:collection_belonging_to_user)
        .and_return(relation)
      allow(JobApplication).to receive(:active).and_return(relation)
      allow(JobApplication).to receive(:sorted).and_return(job_application)
      allow(controller)
        .to receive(:custom_index_sort)
        .and_return([job_application])
    end

    describe 'functional tests' do
      before(:each) do
        get(:index, params: { sort: true })
      end

      it 'returns a 200' do
        expect(response).to have_http_status(200)
      end
      it 'assigns all job_applications as @job_application' do
        expect(assigns(:job_applications)).not_to be_nil
      end
      xit 'renders index' do
        expect(response).to render_template(:index)
      end
    end

    describe 'expected method calls' do
      after(:each) do
        get(:index, params: { sort: true })
      end

      it 'calls #collection_belonging_to_user' do
        expect(controller).to receive(:collection_belonging_to_user)
      end
      it 'calls .active' do
        expect(JobApplication).to receive(:active)
      end
      it 'calls .sorted' do
        expect(JobApplication).to receive(:sorted)
      end
      it 'calls #custom_index_sort' do
        expect(controller).to receive(:custom_index_sort)
      end
    end
  end

  describe 'GET #show' do
    before(:each) do
      stub_before_actions
      get(:show, params: { id: 1 })
    end

    it 'returns a 200' do
      expect(response).to have_http_status(200)
    end
    xit 'renders show' do
      expect(response).to render_template(:show)
    end

    context '@notable, @notes, @note' do
      it 'assigns @contact to @notable' do
        expect(assigns(:notable)).to eq(assigns(:job_application))
      end
      it 'calls #notes on @notable' do
        expect(assigns(:notable)).to receive(:notes)
        get(:show, params: { id: 1 })
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
      { job_application: { active: true } }
    end

    before(:each) do
      allow(controller)
        .to receive(:job_application_params_with_associated_ids)
        .and_return(attr_for_create)
      allow(JobApplication).to receive(:new).and_return(job_application)
    end

    describe 'expected method calls' do
      before(:each) do
        allow(controller).to receive(:save_and_respond).and_return(true)
        allow(controller).to receive(:render).and_return(true)
      end
      after(:each) do
        post(:create, params: { contact: attr_for_create })
      end

      it 'calls #contact_params_with_associated_ids' do
        expect(controller)
          .to receive(:job_application_params_with_associated_ids)
      end
      it 'calls JobApplication.new' do
        expect(JobApplication).to receive(:new).with(attr_for_create)
      end
      it 'calls #save_and_respond' do
        expect(controller).to receive(:save_and_respond).with(job_application)
      end
    end

    context 'with valid params' do
      before(:each) do
        allow(job_application).to receive(:save).and_return(true)
        post(:create, params: { job_application: attr_for_create })
      end

      it 'sets @job_application to a new JobApplication object' do
        expect(assigns(:job_application)).to be_a_new(JobApplication)
      end
      it 'renders the "show" template' do
        expect(response).to render_template('show')
      end
    end

    context 'with invalid params' do
      before(:each) do
        allow(job_application).to receive(:save).and_return(false)
        post(:create, params: { job_application: attr_for_create })
      end

      it 'assigns a newly created but unsaved job_application as @job_application' do
        expect(assigns(:job_application)).to be_a_new(JobApplication)
      end
      it 'responds with unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    let(:attr_for_update) do
      {
        id: 1,
        job_application: { active: 'true' },
        company_name: 'example'
      }
    end

    before(:each) do
      allow(controller)
        .to receive(:job_application_params_with_associated_ids)
        .and_return(attr_for_update)
      stub_before_actions
    end

    context 'with valid params' do
      before(:each) do
        allow(job_application).to receive(:update).and_return(true)
      end

      it 'calls #job_application_params_with_associated_ids' do
        expect(controller)
          .to receive(:job_application_params_with_associated_ids)
        put(:update, params: attr_for_update)
      end
      it 'calls update on the requested job_application' do
        expect(job_application).to receive(:update)
        put(:update, params: attr_for_update)
      end
      it 'assigns the requested job_application as @job_application' do
        put(:update, params: attr_for_update)
        expect(assigns(:job_application)).to eq(job_application)
      end
      it 'renders the "show" template' do
        put(:update, params: attr_for_update)
        expect(response).to render_template('show')
      end
    end

    context 'with invalid params' do
      before(:each) do
        allow(job_application).to receive(:update).and_return(false)
      end

      it 'calls #job_application_params_with_associated_ids' do
        expect(controller)
          .to receive(:job_application_params_with_associated_ids)
        put(:update, params: attr_for_update)
      end
      it 'assigns the job_application as @job_application' do
        put(:update, params: attr_for_update)
        expect(assigns(:job_application)).to eq(job_application)
      end
      it 'responds with unprocessable_entity' do
        put(:update, params: attr_for_update)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      allow(job_application).to receive(:title).and_return(true)
      allow(job_application).to receive(:destroy).and_return(true)
      stub_before_actions
    end

    it 'calls destroy on the requested job_application' do
      expect(job_application).to receive(:destroy)
      delete(:destroy, params: { id: 1 })
    end
    it 'returns JSON' do
      delete(:destroy, params: { id: 1 })
      expect(response.content_type).to eq('application/json')
    end
  end

  describe '#set_company_id' do
    params = { job_application: { company_name: 'foo bar' } }

    before(:each) do
      allow(company).to receive(:id).and_return(1)
      allow(Company).to receive(:get_record_val_by).and_return(company.id)
      allow(@controller).to receive(:params).and_return(params)
    end

    it 'calls Company.get_record_val_by' do
      expect(Company).to receive(:get_record_val_by).with(:name, 'foo bar')
      @controller.send(:set_company_id)
    end
    it 'returns the id of the company object' do
      actual = @controller.send(:set_company_id)
      expect(actual).to eq 1
    end
  end

  describe '#job_application_params_with_associated_ids' do
    let(:job_application_params) { { foo: 'bar' } }

    before(:each) do
      allow(controller).to receive(:set_company_id).and_return(1)
      allow(controller).to receive(:current_user).and_return(user)
      allow(user).to receive(:id).and_return(1)
      allow(controller)
        .to receive(:job_application_params)
        .and_return(job_application_params)
    end
    after(:each) do
      controller.send(:job_application_params_with_associated_ids)
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
      expect(controller).to receive(:job_application_params)
    end
    it 'calls #merge on contact_params' do
      expected_args = { company_id: 1, user_id: 1 }
      expect(job_application_params).to receive(:merge).with(expected_args)
    end
  end

  describe '#set_company_id' do
    let(:params) do
      { job_application: { company_name: 'foo' } }
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
    allow(controller).to receive(:set_job_application)
    allow(controller).to receive(:check_user)
    allow(controller).to receive(:job_application).and_return(job_application)
    controller.instance_eval { @job_application = job_application }
  end
end

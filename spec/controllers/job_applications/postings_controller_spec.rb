require 'rails_helper'

describe JobApplications::PostingsController, type: :controller do
  let(:user) { build(:user, id: 1) }
  let(:posting) { build(:posting) }
  let(:job_application) { build(:job_application) }

  before(:each) { log_in_as(user) }

  describe 'GET #index' do
    let(:relation) do
      ActiveRecord::Relation.new(JobApplications::Posting, 'postings', {})
    end

    before(:each) do
      allow(controller)
        .to receive(:collection_belonging_to_user)
        .and_return(relation)
      allow(JobApplications::Posting).to receive(:sorted).and_return(posting)
      allow(controller)
        .to receive(:custom_index_sort)
        .and_return([posting])
    end

    describe 'functional tests' do
      before(:each) do
        get(:index, params: { sort: true })
      end

      it 'returns a 200' do
        expect(response).to have_http_status(200)
      end
      it 'assigns all postings as @postings' do
        expect(assigns(:postings)).not_to be_nil
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
      it 'calls .sorted' do
        expect(JobApplications::Posting).to receive(:sorted)
      end
      it 'calls #custom_index_sort' do
        expect(controller).to receive(:custom_index_sort)
      end
    end
  end

  describe 'GET #show' do
    before(:each) do
      stub_before_actions
      get(:show, params: { job_application_id: 1 })
    end

    it 'returns a 200' do
      expect(response).to have_http_status(200)
    end
    it 'assigns the requested posting as @posting' do
      expect(assigns(:posting)).to eq(posting)
    end
    xit 'renders show' do
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    before(:each) do
      get(:new, params: { job_application_id: 1 })
    end

    xit 'returns a 200' do
      expect(response.code).to eq '200'
    end
    it 'assigns a new posting as @posting' do
      expect(assigns(:posting)).to be_a_new(JobApplications::Posting)
    end
  end

  describe 'GET #edit' do
    before(:each) do
      stub_before_actions
      get(:edit, params: { job_application_id: 1 })
    end

    it 'returns a 200' do
      expect(response).to have_http_status(200)
    end
    it 'assigns the requested company as @posting' do
      expect(assigns(:posting)).to eq(posting)
    end
    xit 'renders edit' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    let(:attr_for_create) do
      {
        posting: {
          first_name: 'Foo',
          last_name: 'Bar',
          title: '_title',
        },
        job_application_id: 1
      }
    end

    before(:each) do
      allow(controller)
        .to receive(:posting_params_with_associated_ids)
        .and_return(attr_for_create)
    end

    context 'expected method calls' do
      before(:each) do
        allow(JobApplications::Posting).to receive(:new).and_return(posting)
      end
      after(:each) do
        post(:create, params: attr_for_create)
      end

      it 'calls #posting_params_with_associated_ids' do
        expect(controller).to receive(:posting_params_with_associated_ids)
      end
      it 'calls .new on JobApplications::Posting' do
        expect(JobApplications::Posting).to receive(:new).with(attr_for_create)
      end
    end

    context 'with valid params' do
      before(:each) do
        allow(posting).to receive(:job_application).and_return(job_application)
        allow(posting).to receive(:save).and_return(true)
        allow(JobApplications::Posting).to receive(:new).and_return(posting)
        post(:create, params: attr_for_create)
      end

      it 'sets @posting to a new JobApplications::Posting object' do
        expect(assigns(:posting)).to be_a_new(JobApplications::Posting)
      end
      it 'renders JSON' do
        expect(response.content_type).to eq('application/json')
      end
      it 'returns a 201' do
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      before(:each) do
        allow(posting).to receive(:save).and_return(false)
        allow(JobApplications::Posting).to receive(:new).and_return(posting)
        post(:create, params: attr_for_create)
      end

      it 'assigns a newly created but unsaved posting as @posting' do
        expect(assigns(:posting)).to be_a_new(JobApplications::Posting)
      end
      it 'returns a 409 status code' do
        expect(response).to have_http_status(409)
      end
    end
  end

  describe 'PUT #update' do
    let(:attr_for_update) do
      {
        job_applications_posting: { content: '' },
        job_application_id: 2
      }
    end

    before(:each) do
      stub_before_actions
    end

    context 'with valid params' do
      before(:each) do
        allow(posting).to receive(:job_application).and_return(job_application)
        allow(posting).to receive(:update).and_return(true)
      end

      it 'assigns the requested posting as @posting' do
        put(:update, params: attr_for_update)
        expect(assigns(:posting)).to eq(posting)
      end
      it 'calls update on the requested posting' do
        expect(posting).to receive(:update)
        put(:update, params: attr_for_update)
      end
      it 'returns a 200' do
        put(:update, params: attr_for_update)
        expect(response).to have_http_status(:success)
      end
    end

    context 'with invalid params' do
      before(:each) do
        allow(posting).to receive(:update).and_return(false)
        put(:update, params: attr_for_update)
      end

      it 'assigns the posting as @posting' do
        expect(assigns(:posting)).to eq(posting)
      end
      it 'returns a 409 status code' do
        expect(response).to have_http_status(409)
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      allow(posting).to receive(:job_application).and_return(job_application)
      allow(posting).to receive(:destroy).and_return(true)
      stub_before_actions
    end

    it 'calls destroy on the requested posting' do
      expect(posting).to receive(:destroy)
      delete(:destroy, params: { job_application_id: 1 })
    end

    it 'responds with JSON' do
      delete(:destroy, params: { job_application_id: 1 })
      expect(response.content_type).to eq('application/json')
    end
  end

  describe '#posting_params_with_associated_ids' do
    let(:params) { { job_application_id: 1 } }

    before(:each) do
      allow(controller).to receive(:params).and_return(params)
      allow(controller)
        .to receive(:posting_params)
        .and_return({})
    end
    after(:each) do
      controller.send(:posting_params_with_associated_ids)
    end

    it 'calls #posting_params' do
      expect(controller).to receive(:posting_params)
    end
    it 'calls #merge on contact_params' do
      posting_params = controller.send(:posting_params)
      expected_args = { job_application_id: 1 }
      expect(posting_params).to receive(:merge).with(expected_args)
    end
  end

  private

  def stub_before_actions
    allow(controller).to receive(:set_posting)
    allow(controller).to receive(:check_user)
    allow(controller).to receive(:posting).and_return(posting)
    controller.instance_eval { @posting = posting }
  end
end

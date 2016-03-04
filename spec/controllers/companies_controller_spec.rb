require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  let(:user) { build(:user, id: 1) }
  let(:company) { build(:company) }
  let(:job_application) { build(:job_application) }

  before(:each) { log_in_as(user) }

  describe 'GET #index' do
    before(:each) do
      allow(@controller)
        .to receive(:search_and_sort_index)
        .and_return([:foo, :bar])
      get(:index)
    end

    it 'returns a 200' do
      expect(response).to have_http_status(200)
    end
    it 'assigns all companies as @companies' do
      expect(assigns(:companies)).to eq([:foo, :bar])
    end
    it 'renders index' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    before(:each) do
      allow(Company).to receive(:find).and_return(company)
      allow(controller)
        .to receive(:contacts_belonging_to_user_and_current_company)
        .and_return('contacts')
      allow(controller)
        .to receive(:job_applications_belonging_to_user_and_current_company)
        .and_return('job_applications')
      get(:show, id: 'example-company')
    end

    it 'returns a 200' do
      expect(response).to have_http_status(200)
    end
    it 'assigns the requested company as @company' do
      expect(assigns(:company)).to eq(company)
    end
    it 'renders show' do
      expect(response).to render_template(:show)
    end
    describe '@contacts' do
      it 'assigns results to @contacts' do
        expect(assigns(:contacts)).to eq 'contacts'
      end
    end
    describe '@job_applications' do
      it 'assigns results to @job_applications' do
        expect(assigns(:job_applications)).to eq 'job_applications'
      end
    end
  end

  describe 'GET #new' do
    it 'assigns a new company as @company' do
      get(:new)
      expect(assigns(:company)).to be_a_new(Company)
    end
  end

  describe 'POST #create' do
    let(:attr_for_create) do
      { name: 'foo', website: 'www.example.com', category: 'bar' }
    end

    before(:each) do
      allow(Company).to receive(:new).and_return(company)
    end

    context 'with valid params' do
      before(:each) do
        allow(company).to receive(:save).and_return(true)
        post(:create, company: attr_for_create)
      end

      it 'sets @company to a new Company object' do
        expect(assigns(:company)).to be_a_new(Company)
      end
      it 'redirects to the created company' do
        expect(response).to redirect_to(company)
      end
    end

    context 'with invalid params' do
      before(:each) do
        allow(company).to receive(:save).and_return(false)
        post(:create, company: attr_for_create)
      end

      it 'assigns a newly created but unsaved company as @company' do
        expect(assigns(:company)).to be_a_new(Company)
      end

      it 're-renders the "new" template' do
        expect(response).to render_template('new')
      end
    end
  end

  describe '#contacts_belonging_to_user_and_current_company' do
    let(:relation) do
      ActiveRecord::Relation.new(Contact, 'contacts')
    end

    before(:each) do
      allow(user).to receive(:id).and_return(1)
      allow(company).to receive(:id).and_return(2)
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:company).and_return(company)
      allow(Contact).to receive(:belonging_to_user).and_return(relation)
      allow(relation).to receive(:where).and_return(relation)
    end
    after(:each) do
      controller.send(:contacts_belonging_to_user_and_current_company)
    end

    it 'calls #current_user' do
      expect(controller).to receive(:current_user)
    end
    it 'calls #id on current_user' do
      expect(controller.current_user).to receive(:id)
    end
    it 'calls .belonging_to_user' do
      expect(Contact).to receive(:belonging_to_user).with(1)
    end
    it 'calls .where on results of .belonging_to_user' do
      expect(relation).to receive(:where).with(company_id: 2)
    end
  end

  describe '#job_applications_belonging_to_user_and_current_company' do
    let(:relation) do
      ActiveRecord::Relation.new(JobApplication, 'job_applications')
    end

    before(:each) do
      allow(user).to receive(:id).and_return(1)
      allow(company).to receive(:id).and_return(2)
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:company).and_return(company)
      allow(JobApplication).to receive(:belonging_to_user).and_return(relation)
      allow(relation).to receive(:where).and_return(relation)
    end
    after(:each) do
      controller.send(:job_applications_belonging_to_user_and_current_company)
    end

    it 'calls #current_user' do
      expect(controller).to receive(:current_user)
    end
    it 'calls #id on current_user' do
      expect(controller.current_user).to receive(:id)
    end
    it 'calls .belonging_to_user' do
      expect(JobApplication).to receive(:belonging_to_user).with(1)
    end
    it 'calls .where on results of .belonging_to_user' do
      expect(relation).to receive(:where).with(company_id: 2)
    end
  end
end

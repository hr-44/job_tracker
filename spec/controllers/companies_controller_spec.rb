require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  let(:user) { build(:user, id: 1) }
  let(:company) { build(:company) }
  let(:job_application) { build(:job_application) }

  describe 'GET #index' do
    before(:each) do
      log_in_as(user)
      allow(@controller)
        .to receive(:search_filter_sort)
        .and_return([:foo, :bar])
      get(:index)
    end

    it 'returns a 200' do
      expect(response).to have_http_status(200)
    end
    it 'assigns all companies as @companies' do
      expect(assigns(:companies)).to eq([:foo, :bar])
    end
    xit 'renders index' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    before(:each) do
      log_in_as(user)
      allow(Company).to receive(:find).and_return(company)
      allow(controller)
        .to receive(:contacts_belonging_to_user_and_current_company)
        .and_return('contacts')
      allow(controller)
        .to receive(:job_applications_belonging_to_user_and_current_company)
        .and_return('job_applications')
      get(:show, params: { id: 'example-company' })
    end

    it 'returns a 200' do
      expect(response).to have_http_status(200)
    end
    it 'assigns the requested company as @company' do
      expect(assigns(:company)).to eq(company)
    end
    xit 'renders show' do
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

  describe 'POST #create' do
    let(:attr_for_create) do
      { name: 'foo', website: 'www.example.com', category: 'bar' }
    end

    before(:each) do
      log_in_as(user)
      allow(Company).to receive(:new).and_return(company)
    end

    context 'with valid params' do
      before(:each) do
        allow(company).to receive(:save).and_return(true)
        post(:create, params: { company: attr_for_create })
      end

      it 'sets @company to a new Company object' do
        expect(assigns(:company)).to be_a_new(Company)
      end
      it 'responds with "show" template' do
        expect(response).to render_template('show')
      end
    end

    context 'with invalid params' do
      before(:each) do
        allow(company).to receive(:save).and_return(false)
        post(:create, params: { company: attr_for_create })
      end

      it 'assigns a newly created but unsaved company as @company' do
        expect(assigns(:company)).to be_a_new(Company)
      end

      it 'responds with unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    let(:attr_for_update) do
      { name: 'foo' }
    end

    before(:each) do
      log_in_as(user)
      allow(Company).to receive(:find).and_return(company)
    end

    context 'with valid params' do
      before(:each) do
        allow(company).to receive(:update).and_return(true)
      end

      it 'calls #update on the company' do
        expect(company).to receive(:update)
        put(:update, params: { id: 1, company: attr_for_update })
      end
      it 'renders the "show" template' do
        put(:update, params: { id: 1, company: attr_for_update })
        expect(response).to render_template('show')
      end
    end

    context 'with invalid params' do
      before(:each) do
        allow(company).to receive(:update).and_return(false)
        put(:update, params: { id: 1, company: attr_for_update })
      end

      it 'responds with unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '#contacts_belonging_to_user_and_current_company' do
    let(:relation) do
      ActiveRecord::Relation.new(Contact, 'contacts', {})
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
      ActiveRecord::Relation.new(JobApplication, 'job_applications', {})
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

  describe '#default_sorting_column' do
    it 'returns "companies.name"' do
      actual = controller.send(:default_sorting_column)
      expect(actual).to eq 'companies.name'
    end
  end

  describe '#sort_col_and_dir' do
    before(:each) do
      allow(controller).to receive(:sort_column).and_return('foo')
      allow(controller).to receive(:sort_direction).and_return('bar')
    end

    it 'calls #sort_column' do
      expect(controller).to receive(:sort_column)
      controller.send(:sort_col_and_dir)
    end
    it 'calls #sort_direction' do
      expect(controller).to receive(:sort_direction)
      controller.send(:sort_col_and_dir)
    end
    it 'returns this string' do
      actual = controller.send(:sort_col_and_dir)
      expect(actual).to eq 'foo bar'
    end
  end

  describe '#search_filter_sort' do
    let(:relation) { double('Company::ActiveRecord_Relation') }
    let(:params) { { search: 'unicorn', category_names: ['foo', 'bar'] } }
    let(:sort_col_and_dir) { 'sort_col_and_dir' }

    before(:each) do
      allow(controller).to receive(:params).and_return(params)
      allow(Company).to receive(:search_and_filter).and_return(relation)
      allow(relation).to receive(:order)
      allow(controller).to receive(:sort_col_and_dir).and_return(sort_col_and_dir)
    end
    after(:each) do
      controller.send(:search_filter_sort)
    end

    it 'calls .search_and_filter on Company' do
      expect(Company)
        .to receive(:search_and_filter)
        .with('unicorn', ['foo', 'bar'])
    end
    it 'calls .order on the relation' do
      expect(relation).to receive(:order).with(sort_col_and_dir)
    end
  end
end

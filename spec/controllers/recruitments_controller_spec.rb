require 'rails_helper'

describe RecruitmentsController, type: :controller do
  let(:recruitment) { build(:recruitment) }
  let(:user) { build(:user) }
  let(:company) { build(:company) }

  before(:each) do
    log_in_as(user)
  end

  describe 'GET #new' do
    before(:each) do
      allow(company).to receive(:id).and_return(1)
      allow(Company).to receive(:find).and_return(company)
      get(:new, params: { company_id: 1 })
    end

    xit 'renders the new template' do
      expect(response).to render_template 'new'
    end
    xit 'returns a 200 status' do
      expect(response).to have_http_status 200
    end
    it 'assigns a new Recruitment object to @recruitment' do
      actual = assigns(:recruitment)
      expect(actual).to be_a_new Recruitment
    end
  end

  describe 'POST #create' do
    let(:agency) { build(:company) }
    let(:client) { build(:company) }

    context 'adding a client to an agency' do
      let(:expected_recruitment_params) do
        {
          agency_id: 1,
          client_id: 2,
          recruit_id: 3
        }
      end

      before(:each) do
        allow(agency).to receive(:id).and_return(1)
        allow(client).to receive(:id).and_return(2)
        allow(user).to receive(:id).and_return(3)
        allow(controller).to receive(:company).and_return(agency)
        allow(agency).to receive(:agency?).and_return(true)
        allow(Company).to receive(:find).and_return(agency)
        allow(Company).to receive(:find_by_name).and_return(client)
        allow(Recruitment).to receive(:new).and_return(recruitment)
        allow(recruitment).to receive(:save).and_return(true)
      end

      context 'when recruitment object does not save' do
        before(:each) do
          allow(recruitment).to receive(:save).and_return(false)
          post(:create, params: { company_id: 1, recruitment: { client_name: 'foo' } })
        end

        xit 'renders the new template' do
          expect(response).to render_template :new
        end
      end

      context 'functional tests' do
        before(:each) do
          post(:create, params: { company_id: 1, recruitment: { client_name: 'foo' } })
        end

        it 'assigns a new Recruitment object to @recruitment' do
          expect(assigns(:recruitment)).to be_a_new Recruitment
        end
        it 'assigns agency to @company' do
          expect(assigns(:company)).to eq agency
        end
        it 'redirects to agency' do
          expect(response).to redirect_to(agency)
        end
      end

      context 'expected method calls' do
        after(:each) do
          post(:create, params: { company_id: 1, recruitment: { client_name: 'foo' } })
        end

        it 'calls #load_company' do
          expect(controller).to receive(:load_company)
        end
        it 'calls #build_recruitment_params' do
          expect(controller).to receive(:build_recruitment_params)
        end
        it 'calls #set_client_id' do
          expect(controller).to receive(:set_client_id)
        end
        it 'calls #recruitment_params_with_associated_ids' do
          expect(controller).to receive(:recruitment_params_with_associated_ids)
        end
        # TODO: figure out how params are different in Rails 5, vs Rails 4
        xit 'calls for a new Recruitment object with these params' do
          expect(Recruitment).to receive(:new).with(expected_recruitment_params)
        end
      end
    end

    context 'adding an agency to a client' do
      let(:expected_recruitment_params) do
        {
          client_id: 1,
          agency_id: 2,
          recruit_id: 3
        }
      end

      before(:each) do
        allow(client).to receive(:id).and_return(1)
        allow(agency).to receive(:id).and_return(2)
        allow(user).to receive(:id).and_return(3)
        allow(controller).to receive(:company).and_return(client)
        allow(client).to receive(:agency?).and_return(false)
        allow(Company).to receive(:find).and_return(client)
        allow(Company).to receive(:find_by_name).and_return(agency)
        allow(Recruitment).to receive(:new).and_return(recruitment)
        allow(recruitment).to receive(:save).and_return(true)
      end

      context 'when recruitment object does not save' do
        before(:each) do
          allow(recruitment).to receive(:save).and_return(false)
          post(:create, params: { company_id: 1, recruitment: { agency_name: 'foo' } })
        end

        xit 'renders the new template' do
          expect(response).to render_template :new
        end
      end

      context 'functional tests' do
        before(:each) do
          post(:create, params: { company_id: 2, recruitment: { agency_name: 'bar' } })
        end

        it 'assigns a new Recruitment object to @recruitment' do
          expect(assigns(:recruitment)).to be_a_new Recruitment
        end
        it 'assigns client to @company' do
          expect(assigns(:company)).to eq client
        end
        it 'redirects to client' do
          expect(response).to redirect_to(client)
        end
      end

      context 'expected method calls' do
        after(:each) do
          post(:create, params: { company_id: 1, recruitment: { agency_name: 'foo' } })
        end

        it 'calls #load_company' do
          expect(controller).to receive(:load_company)
        end
        it 'calls #build_recruitment_params' do
          expect(controller).to receive(:build_recruitment_params)
        end
        it 'calls #set_agency_id' do
          expect(controller).to receive(:set_agency_id)
        end
        it 'calls #recruitment_params_with_associated_ids' do
          expect(controller).to receive(:recruitment_params_with_associated_ids)
        end
        # TODO: figure out how params are different in Rails 5, vs Rails 4
        xit 'calls for a new Recruitment object with these params' do
          expect(Recruitment).to receive(:new).with(expected_recruitment_params)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:destroy_params) do
      { company_id: 1, id: 1 }
    end

    before(:each) do
      allow(Company).to receive(:find).and_return(company)
      allow(controller).to receive(:company).and_return(company)
      allow(Recruitment).to receive(:find).and_return(recruitment)
      allow(controller).to receive(:recruitment).and_return(recruitment)
      allow(recruitment).to receive(:destroy)
    end

    it 'calls #destroy on the recruitment object' do
      expect(recruitment).to receive(:destroy)
      delete(:destroy, params: destroy_params)
    end
    it 'redirects to company' do
      delete(:destroy, params: destroy_params)
      expect(response).to redirect_to company
    end
  end
end

require 'rails_helper'

RSpec.describe NotesController, type: :controller do
  let(:user) { build(:user, id: 1) }
  let(:note) { build(:note, id: 1) }
  let(:contact) { build(:contact) }
  let(:job_application) { build(:job_application, id: 1) }

  before(:each) { log_in_as(user) }

  describe 'GET #index' do
    before(:each) do
      allow(Note).to receive(:sorted).and_return(note)
      allow(@controller).to receive(:custom_index_sort).and_return([note])
      get(:index, params: { sort: true })
    end

    it 'returns a 200' do
      expect(response).to have_http_status(200)
    end
    it 'assigns all notes as @notes' do
      expect(assigns(:notes)).to eq([note])
    end
    xit 'renders index' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    shared_examples_for '#show via host resource' do
      it 'returns a 200' do
        expect(response).to have_http_status(200)
      end
      it 'assigns the requested note as @note' do
        expect(assigns(:note)).to eq(note)
      end
      xit 'renders show' do
        expect(response).to render_template(:show)
      end
    end

    context 'Nested inside of contacts/' do
      it_behaves_like '#show via host resource' do
        before(:each) do
          stub_note
          stub_user
          stub_notable(contact)
          get(:show, params: { contact_id: 'joe-schmoe', id: 1 })
        end
      end
    end

    context 'Nested inside of job_applications/' do
      it_behaves_like '#show via host resource' do
        before(:each) do
          stub_note
          stub_user
          stub_notable(job_application)
          get(:show, params: { job_application_id: 1, id: 1 })
        end
      end
    end
  end

  describe 'POST #create' do
    shared_examples_for '#create via host resource' do
      before(:each) do
        allow(@controller).to receive(:build_note).and_return(note)
      end

      describe 'expected method calls' do
        it 'calls #build_note' do
          allow(controller).to receive(:render)
          expect(controller).to receive(:build_note)
          post(:create, params: post_attr)
        end
      end

      context 'with valid params' do
        before(:each) do
          allow(note).to receive(:save).and_return(true)
          post(:create, params: post_attr)
        end

        it 'sets @note to a new Note object' do
          expect(assigns(:note)).to be_a_new(Note)
        end
        it 'renders the "show" template' do
          expect(response).to render_template('show')
        end
      end

      context 'with invalid params' do
        before(:each) do
          allow(note).to receive(:save).and_return(false)
          post(:create, params: post_attr)
        end

        it 'assigns a newly created but unsaved note as @note' do
          expect(assigns(:note)).to be_a_new(Note)
        end
        it 'responds with unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'Nested inside of contacts/' do
      it_behaves_like '#create via host resource' do
        let(:notable) { contact }
        let(:post_attr) do
          {
            note: { content: '' },
            contact_id: 1
          }
        end

        before(:each) do
          stub_notable(notable)
        end
      end
    end

    context 'Nested inside of job_application/' do
      it_behaves_like '#create via host resource' do
        let(:notable) { job_application }
        let(:post_attr) do
          {
            note: { content: '' },
            job_application_id: 1
          }
        end

        before(:each) do
          stub_notable(notable)
        end
      end
    end
  end

  describe 'PUT #update' do
    shared_examples_for '#update via host resource' do
      before(:each) do
        stub_user
        stub_note
        stub_notable(notable)
      end

      context 'with valid params' do
        before(:each) do
          allow(note).to receive(:update).and_return(true)
        end

        it 'assigns the requested note as @note' do
          put(:update, params: update_attr)
          expect(assigns(:note)).to eq(note)
        end
        it 'calls update on the requested note' do
          expect(note).to receive(:update)
          put(:update, params: update_attr)
        end
        it 'renders the "show" template' do
          put(:update, params: update_attr)
          expect(response).to render_template('show')
        end
      end

      context 'with invalid params' do
        before(:each) do
          allow(note).to receive(:update).and_return(false)
          put(:update, params: update_attr)
        end

        it 'assigns the note as @note' do
          expect(assigns(:note)).to eq(note)
        end
        it 'responds with unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'Nested inside of contacts/' do
      it_behaves_like '#update via host resource' do
        let(:notable) { contact }
        let(:update_attr) do
          {
            note: { content: '' },
            contact_id: 1,
            id: 1
          }
        end
      end
    end

    context 'Nested inside of job_application/' do
      it_behaves_like '#update via host resource' do
        let(:notable) { job_application }
        let(:update_attr) do
          {
            note: { content: '' },
            job_application_id: 1,
            id: 1
          }
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    shared_examples_for '#destroy via host resource' do
      before(:each) do
        stub_note
        stub_user
        stub_notable(notable)
      end

      it 'calls destroy on the requested note' do
        expect(note).to receive(:destroy)
        delete(:destroy, params: delete_opts)
      end
      it 'returns JSON' do
        delete(:destroy, params: delete_opts)
        expect(response.content_type).to eq('application/json')
      end
    end

    context 'Nested inside of contacts/' do
      it_behaves_like '#destroy via host resource' do
        let(:notable) { contact }
        let(:delete_opts) { { id: 1, contact_id: 'joe-schmoe' } }
      end
    end

    context 'Nested inside of job_applications/' do
      before(:each) do
        allow(job_application).to receive(:title).and_return(true)
      end

      it_behaves_like '#destroy via host resource' do
        let(:notable) { job_application }
        let(:delete_opts) { { id: 1, job_application_id: 1 } }
      end
    end
  end

  describe '#set_note' do
    let(:params) { { id: 1 } }

    before(:each) do
      allow(controller).to receive(:params).and_return(params)
      allow(Note).to receive(:find).and_return(note)
    end

    it 'calls .find on the Note' do
      expect(Note).to receive(:find).with(params[:id])
      controller.send(:set_note)
    end
    it 'assigns a value for @note' do
      controller.send(:set_note)
      expect(assigns(:note)).not_to be_nil
    end
  end

  describe '#build_note' do
    let(:params) do
      { note: { content: 'foo' } }
    end
    let(:notes) { double('notes', build: true) }
    let(:notable) { double('notable', notes: true) }

    before(:each) do
      allow(controller).to receive(:params).and_return(params)
      allow(controller).to receive(:current_user).and_return(user)
      allow(user).to receive(:id).and_return(1)
      stub_notable(notable)
      allow(notable).to receive(:notes).and_return(notes)
    end
    after(:each) do
      controller.send(:build_note)
    end

    it 'calls #notes upon notable' do
      expect(assigns(:notable)).to receive(:notes)
    end
    it 'calls #build upon @notable.notes' do
      expected_args = { content: 'foo', user_id: 1 }
      expect(notes).to receive(:build).with(expected_args)
    end
  end

  describe '#load_notable' do
    let(:request_path) { ['', 'foos', '1', 'bars', '2'] }
    let(:model) { double('FooBar', find: true) }

    before(:each) do
      allow(controller).to receive(:request_path).and_return(request_path)
      allow(controller).to receive(:inflect).and_return(model)
    end

    it 'calls #request_path' do
      expect(controller).to receive(:request_path)
      controller.send(:load_notable)
    end
    it 'calls #inflect' do
      expect(controller).to receive(:inflect).with('foos')
      controller.send(:load_notable)
    end
    it 'calls .find on the model' do
      expect(model).to receive(:find).with('1')
      controller.send(:load_notable)
    end
    it 'assigns a value to @notable' do
      controller.send(:load_notable)
      expect(assigns(:notable)).not_to be_nil
    end
  end

  describe '#request_path' do
    let(:request) { double('request', path: '/foos/1/bars/2') }

    before(:each) do
      allow(controller).to receive(:request).and_return(request)
    end
    it 'returns an array of path segments' do
      actual = controller.send(:request_path)
      expected = ['', 'foos', '1', 'bars', '2']
      expect(actual).to eq expected
    end
  end

  describe '#inflect' do
    it 'returns correct constant for Contact' do
      actual = controller.send(:inflect, 'contacts')
      expect(actual).to eq Contact
    end
    it 'returns correct constant for JobApplication' do
      actual = controller.send(:inflect, 'job_applications')
      expect(actual).to eq JobApplication
    end
  end

  private

  def stub_note
    allow(controller).to receive(:set_note)
    allow(controller).to receive(:note).and_return(note)
    controller.instance_eval { @note = note }
  end

  def stub_user
    allow(controller).to receive(:check_user)
  end

  def stub_notable(notable)
    allow(controller).to receive(:load_notable)
    controller.instance_eval { @notable = notable }
  end
end

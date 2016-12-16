require 'rails_helper'

RSpec.describe SearchSuggestionsController, type: :controller do
  let(:user) { build(:user) }

  describe '#index' do
    before(:each) do
      stub_auth(user)
      allow(SearchSuggestion)
        .to receive(:terms_for)
        .and_return(foo: 'bar')
      term = '_term'
      key = '_key'
      get(:index, params: { term: term, key: key })
    end

    it 'returns a 200' do
      expect(response).to have_http_status(200)
    end
    it 'calls SearchSuggestion.terms_for' do
      expect(SearchSuggestion).to have_received(:terms_for)
    end
    it 'renders json' do
      expect(response.header['Content-Type']).to include 'application/json'
    end
    it 'renders "index"' do
      expect(response).to render_template('index')
    end
  end
end

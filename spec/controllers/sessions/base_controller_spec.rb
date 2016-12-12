require 'rails_helper'

describe Sessions::BaseController, type: :controller do
  describe 'DELETE #destroy' do
    context 'if logged_in?' do
      before(:each) do
        allow(@controller).to receive(:logged_in?).and_return(true)
      end

      it 'logs out' do
        expect(@controller).to receive(:log_out)
        delete(:destroy)
      end
    end

    it 'responds with JSON' do
      delete(:destroy)
      expect(response.content_type).to eq 'application/json'
    end
  end
end

require 'rails_helper'

describe RoutesController, type: :controller do
  let(:routes) { [ foo: { bar: 'qux' } ] }

  describe 'GET #index' do
    before(:each) do
      allow(controller).to receive(:routes!).and_return(true)
    end

    it 'renders index' do
      get(:index)
      expect(response).to render_template(:index)
    end
    it 'calls #routes!' do
      expect(controller).to receive(:routes!)
      get(:index)
    end
  end

  describe '#routes!' do
    context 'when caching is ok' do
      before(:each) do
        allow(controller).to receive(:routes?).and_return(false)
        allow(RouteReporter).to receive(:routes).and_return(routes)
      end

      it 'does not call .routes! on RouteReporter' do
        expect(RouteReporter).not_to receive(:routes!)
        controller.send(:routes!)
      end

      it 'sets a value for @routes' do
        controller.send(:routes!)
        expect(assigns(:routes)).to eq(routes)
      end
    end

    context 'when refreshing the cache' do
      before(:each) do
        allow(controller).to receive(:routes?).and_return(true)
        allow(RouteReporter).to receive(:routes).and_return(routes)
      end

      it 'calls .routes! on RouteReporter' do
        expect(RouteReporter).to receive(:routes!)
        controller.send(:routes!)
      end

      it 'sets a value for @routes' do
        controller.send(:routes!)
        expect(assigns(:routes)).to eq(routes)
      end
    end
  end

  describe '#routes?' do
    context 'when passed params[:refresh]' do
      before(:each) do
        allow(controller).to receive(:params).and_return({ refresh: 'thx' })
        allow(RouteReporter).to receive(:routes).and_return(nil)
      end

      it 'returns true' do
        actual = controller.send(:routes?)
        expect(actual).to be_truthy
      end
    end

    context 'when RouteReporter has not cached routes' do
      before(:each) do
        allow(controller).to receive(:params).and_return({})
        allow(RouteReporter).to receive(:routes).and_return(nil)
      end

      it 'returns true' do
        actual = controller.send(:routes?)
        expect(actual).to be_truthy
      end
    end

    context 'otherwise...' do
      before(:each) do
        allow(controller).to receive(:params).and_return({})
        allow(RouteReporter).to receive(:routes).and_return(true)
      end

      it 'returns false' do
        actual = controller.send(:routes?)
        expect(actual).to be_falsey
      end
    end
  end
end

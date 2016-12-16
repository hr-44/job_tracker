require 'rails_helper'

describe RouteReporter do
  describe '#routes!' do
    let(:routes) do
      # The real routes are actually an ActionDispatch::Journey::Routes object.
      # It includes `Enumerable`. For simplicity's sake, stubbing for an Array.
      [
        { foo: 'bar' },
        { bar: 'foo' }
      ]
    end

    before(:each) do
      allow(Rails.application.routes).to receive(:routes).and_return(routes)
      allow(described_class).to receive(:extract_info).and_return(true)
    end

    it 'calls .routes' do
      expect(Rails.application.routes).to receive(:routes)
      described_class.routes!
    end

    it 'calls #extract_info for each object' do
      len = routes.length
      expect(described_class).to receive(:extract_info).exactly(len).times
      described_class.routes!
    end

    it 'sets a value for @routes' do
      described_class.routes!
      expect(described_class.routes).not_to be_nil
    end
  end

  describe '#extract_info' do
    # The real thing is an ActionDispatch::Journey::Route object
    let(:route) { double('mock_route') }

    before(:each) do
      allow(route).to receive(:verb).and_return('HTTP verb')
      allow(route).to receive_message_chain('path.spec.to_s').and_return('/path/to/nowhere')
      allow(route).to receive(:defaults).and_return({
        controller: 'controller',
        action: 'action'
      })
    end

    it 'returns this result' do
      expected = {
        verb: 'HTTP verb',
        path: '/path/to/nowhere',
        controller: 'controller',
        action: 'action'
      }

      actual = described_class.send(:extract_info, route)
      expect(actual).to eq(expected)
    end
  end
end

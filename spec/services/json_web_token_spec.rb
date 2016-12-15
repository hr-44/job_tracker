require 'rails_helper'

describe JsonWebToken do
  let(:secret_key_base) { 'fake key base' }

  before(:each) do
    allow(Rails.application.secrets)
      .to receive(:secret_key_base)
      .and_return('fake key base')
  end

  shared_examples_for 'same value for secret_key_base' do
    it 'looks for secret_key_base' do
      expect(Rails.application.secrets).to receive(:secret_key_base)
    end
  end

  describe '.encode' do
    let(:payload) { { user_id: 1 } }

    it_behaves_like 'same value for secret_key_base' do
      after(:each) { described_class.encode(payload) }
    end

    it 'calls .encode on JWT' do
      expect(JWT).to receive(:encode).with(payload, secret_key_base)
      described_class.encode(payload)
    end

    it 'returns an encoded token' do
      actual = described_class.encode(payload)
      expect(actual).to be_truthy
    end
  end

  describe '.decode' do
    context 'recovering from an error' do
      let(:token) { 'bad token' }

      before(:each) do
        allow(JWT).to receive(:decode)
          .with(token, secret_key_base)
          .and_raise(JWT::DecodeError)
      end

      it_behaves_like 'same value for secret_key_base' do
        after(:each) { described_class.decode(token) }
      end

      it 'calls .decode on JWT' do
        expect(JWT).to receive(:decode).with(token, secret_key_base)
        described_class.decode(token)
      end

      it 'returns nil' do
        actual = described_class.decode(token)
        expect(actual).to be_nil
      end
    end

    context 'successfully decoding token' do
      let(:token) { 'good token' }

      before(:each) do
        allow(JWT).to receive(:decode). with(token, secret_key_base).and_return('ok')
      end

      it_behaves_like 'same value for secret_key_base' do
        after(:each) { described_class.decode(token) }
      end

      it 'calls .decode on JWT' do
        expect(JWT).to receive(:decode).with(token, secret_key_base)
        described_class.decode(token)
      end

      it 'returns an decoded token' do
        actual = described_class.decode(token)
        expect(actual).to be_truthy
      end
    end
  end
end

require 'rails_helper'

class DummyController < ApplicationController
  include OwnResources

  before_action :check_user

  def index; end

  private

  def member
    # noop
  end

  def model
    # noop
  end
end

describe OwnResources, type: :controller do
  let(:user)   { build(:user) }
  let(:member) { double('member', user: true) }
  let(:model)  { double('Model', belonging_to_user: true) }
  let(:subject) { DummyController.new }

  describe '#check_user' do
    controller do
      include OwnResources
      before_action :check_user
      def index; end

      private
      def member; end
      def model; end
    end

    it 'calls #correct_user?' do
      allow(controller).to receive(:correct_user?).and_return(true)
      expect(controller).to receive(:correct_user?)
      controller.send(:check_user)
    end

    context 'when #correct_user? is false' do
      before(:each) do
        allow(controller).to receive(:correct_user?).and_return(false)
        get(:index)
      end

      it 'renders shared/errors' do
        expect(response).to render_template('shared/errors')
      end
      it 'returns a 401' do
        expect(response).to have_http_status(:unauthorized)
      end
      it 'sets value for @errors' do
        expect(assigns(:errors)).not_to be_nil
      end
    end
  end

  describe '#correct_user?' do
    before(:each) do
      allow(subject).to receive(:member).and_return(member)
      allow(member).to receive(:user).and_return(user)
      allow(subject).to receive(:current_user?)
    end
    after(:each) do
      subject.send(:correct_user?)
    end
    it 'calls #current_user?' do
      expect(subject).to receive(:current_user?).with(user)
    end
    it 'calls #member' do
      expect(subject).to receive(:member)
    end
    it 'calls #user on the results of member' do
      saved_member = subject.send :member
      expect(saved_member).to receive(:user)
    end
  end

  describe '#collection_belonging_to_user' do
    before(:each) do
      allow(user).to receive(:id).and_return(1)
      allow(subject).to receive(:current_user).and_return(user)
      allow(subject).to receive(:model).and_return(model)
    end
    after(:each) do
      subject.send(:collection_belonging_to_user)
    end

    it 'calls #model' do
      expect(subject).to receive(:model)
    end
    it 'calls #calls belonging_to_user on the model' do
      expect(model).to receive(:belonging_to_user).with(1)
    end
    it 'calls #current_user' do
      expect(subject).to receive(:current_user)
    end
    it 'calls #id on current_user' do
      expect(subject.current_user).to receive(:id)
    end
  end
end

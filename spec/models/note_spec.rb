require 'rails_helper'

describe Note, type: :model do
  let(:relation) { double('relation') }

  describe '.belonging_to_user_and_contact' do
    context 'required arguments' do
      it 'raises error without required arguments' do
        expect { described_class.belonging_to_user_and_contact(user_id: 1) }
          .to raise_error(ArgumentError)
      end
      it 'raises error without required arguments' do
        expect { described_class.belonging_to_user_and_contact(contact_id: 1) }
          .to raise_error(ArgumentError)
      end
      it 'does not raise error with required arguments' do
        allow(described_class).to receive(:belonging_to_user).and_return(relation)
        allow(relation).to receive(:where)

        args = { contact_id: 1, user_id: 1 }
        expect { described_class.belonging_to_user_and_contact(args) }
          .not_to raise_error
      end
    end

    context 'expected method calls' do
      before(:each) do
        allow(described_class).to receive(:belonging_to_user).and_return(relation)
        allow(relation).to receive(:where).and_return(true)
      end

      it 'calls belonging_to_user with a user_id' do
        expect(described_class).to receive(:belonging_to_user).with(be_a_kind_of(Integer))
        described_class.belonging_to_user_and_contact(user_id: 1, contact_id: 1)
      end
      it 'calls .where' do
        expect(relation).to receive(:where)
        described_class.belonging_to_user_and_contact(user_id: 1, contact_id: 1)
      end
    end
  end

  describe '.belonging_to_user_and_job_application' do
    context 'required arguments' do
      it 'raises error without required arguments' do
        expect { described_class.belonging_to_user_and_job_application(user_id: 1) }
          .to raise_error(ArgumentError)
      end
      it 'raises error without required arguments' do
        expect { described_class.belonging_to_user_and_job_application(job_application_id: 1) }
          .to raise_error(ArgumentError)
      end
      it 'does not raise error with required arguments' do
        allow(described_class).to receive(:belonging_to_user).and_return(relation)
        allow(relation).to receive(:where)

        args = { job_application_id: 1, user_id: 1 }
        expect { described_class.belonging_to_user_and_job_application(args) }
          .not_to raise_error
      end
    end

    context 'expected method calls' do
      before(:each) do
        allow(described_class).to receive(:belonging_to_user).and_return(relation)
        allow(relation).to receive(:where).and_return(true)
      end

      it 'calls belonging_to_user with a user_id' do
        expect(described_class).to receive(:belonging_to_user).with(be_a_kind_of(Integer))
        described_class.belonging_to_user_and_job_application(user_id: 1, job_application_id: 1)
      end
      it 'calls .where' do
        expect(relation).to receive(:where)
        described_class.belonging_to_user_and_job_application(user_id: 1, job_application_id: 1)
      end
    end
  end
end

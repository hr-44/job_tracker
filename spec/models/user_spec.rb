require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe '.filter_user_info' do
    it 'produces a hash object' do
      filtered_user_info = described_class.filter_user_info(user)
      expect(filtered_user_info).to be_a(Hash)
    end

    it 'does not include these columns in the output' do
      filtered_user_info = described_class.filter_user_info(user)
      forbidden_columns = ['remember_digest', 'password_digest', 'type']

      forbidden_columns.each do |k|
        expect(filtered_user_info.member?(k)).to be_falsey
        expect(filtered_user_info.member?(k.to_sym)).to be_falsey
      end
    end
  end
end

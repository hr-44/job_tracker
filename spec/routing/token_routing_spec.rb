require 'rails_helper'

describe TokenController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: '/token').to route_to('token#create')
    end
  end
end

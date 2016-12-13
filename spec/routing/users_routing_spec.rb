require 'rails_helper'

RSpec.describe UsersController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/profile').to route_to('users#show')
    end

    it 'routes to #create' do
      expect(post: '/profile').to route_to('users#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/profile').to route_to('users#update')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/profile').to route_to('users#update')
    end

    it 'routes to #destroy' do
      expect(delete: '/profile').to route_to('users#destroy')
    end
  end
end

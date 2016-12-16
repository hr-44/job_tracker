require 'rails_helper'

describe RoutesController, type: :routing do
  describe 'routing' do
    it 'root routes to #index' do
      expect(get: '/').to route_to('routes#index')
    end
  end
end

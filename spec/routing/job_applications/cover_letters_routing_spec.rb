require 'rails_helper'

describe JobApplications::CoverLettersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expected = 'job_applications/cover_letters#index'
      expect(get: '/cover_letters').to route_to(expected)
    end
    it 'routes to #show' do
      expected = { controller: 'job_applications/cover_letters', action: 'show',
                   job_application_id: '1' }
      expect(get: '/job_applications/1/cover_letter').to route_to(expected)
    end
    it 'routes to #create' do
      expected = { controller: 'job_applications/cover_letters', action: 'create',
                   job_application_id: '1' }
      expect(post: '/job_applications/1/cover_letter').to route_to(expected)
    end
    it 'routes to #update via PUT' do
      expected = { controller: 'job_applications/cover_letters', action: 'update',
                   job_application_id: '1' }
      expect(put: '/job_applications/1/cover_letter').to route_to(expected)
    end
    it 'routes to #update via PATCH' do
      expected = { controller: 'job_applications/cover_letters', action: 'update',
                   job_application_id: '1' }
      expect(patch: '/job_applications/1/cover_letter').to route_to(expected)
    end
    it 'routes to #destroy' do
      expected = { controller: 'job_applications/cover_letters', action: 'destroy',
                   job_application_id: '1' }
      expect(delete: '/job_applications/1/cover_letter').to route_to(expected)
    end
  end
end

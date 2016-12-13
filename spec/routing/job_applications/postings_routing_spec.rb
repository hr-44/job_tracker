require 'rails_helper'

describe JobApplications::PostingsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/postings').to route_to('job_applications/postings#index')
    end
    it 'routes to #show' do
      expected = { controller: 'job_applications/postings', action: 'show',
                   job_application_id: '1' }
      expect(get: '/job_applications/1/posting').to route_to(expected)
    end
    it 'routes to #create' do
      expected = { controller: 'job_applications/postings', action: 'create',
                   job_application_id: '1' }
      expect(post: '/job_applications/1/posting').to route_to(expected)
    end
    it 'routes to #update via PUT' do
      expected = { controller: 'job_applications/postings', action: 'update',
                   job_application_id: '1' }
      expect(put: '/job_applications/1/posting').to route_to(expected)
    end
    it 'routes to #update via PATCH' do
      expected = { controller: 'job_applications/postings', action: 'update',
                   job_application_id: '1' }
      expect(patch: '/job_applications/1/posting').to route_to(expected)
    end
    it 'routes to #destroy' do
      expected = { controller: 'job_applications/postings', action: 'destroy',
                   job_application_id: '1' }
      expect(delete: '/job_applications/1/posting').to route_to(expected)
    end
  end
end

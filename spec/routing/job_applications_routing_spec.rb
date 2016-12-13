require 'rails_helper'

RSpec.describe JobApplicationsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/job_applications').to route_to('job_applications#index')
    end

    it 'routes to #show' do
      expect(get: '/job_applications/1').to route_to('job_applications#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/job_applications').to route_to('job_applications#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/job_applications/1').to route_to('job_applications#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/job_applications/1').to route_to('job_applications#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/job_applications/1').to route_to('job_applications#destroy', id: '1')
    end

    context 'nested resources' do
      describe NotesController do
        it 'routes to notes#index' do
          expected = { controller: 'notes', action: 'index',
                       job_application_id: '1' }
          expect(get: '/job_applications/1/notes').to route_to(expected)
        end
        it 'routes to notes#show' do
          expected = { controller: 'notes', action: 'show',
                       job_application_id: '1', id: '1' }
          expect(get: '/job_applications/1/notes/1').to route_to(expected)
        end
        it 'routes to notes#create' do
          expected = { controller: 'notes', action: 'create',
                       job_application_id: '1' }
          expect(post: '/job_applications/1/notes').to route_to(expected)
        end
        it 'routes to notes#update via PUT' do
          expected = { controller: 'notes', action: 'update',
                       job_application_id: '1', id: '1' }
          expect(put: '/job_applications/1/notes/1').to route_to(expected)
        end
        it 'routes to notes#update via PATCH' do
          expected = { controller: 'notes', action: 'update',
                       job_application_id: '1', id: '1' }
          expect(patch: '/job_applications/1/notes/1').to route_to(expected)
        end
        it 'routes to notes#destroy' do
          expected = { controller: 'notes', action: 'destroy',
                       job_application_id: '1', id: '1' }
          expect(delete: '/job_applications/1/notes/1').to route_to(expected)
        end
      end
    end
  end
end

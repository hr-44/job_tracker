require 'rails_helper'

RSpec.describe ContactsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/contacts').to route_to('contacts#index')
    end

    it 'routes to #show' do
      expect(get: '/contacts/1').to route_to('contacts#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/contacts').to route_to('contacts#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/contacts/1').to route_to('contacts#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/contacts/1').to route_to('contacts#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/contacts/1').to route_to('contacts#destroy', id: '1')
    end

    context 'nested resources' do
      describe NotesController do
        it 'routes to notes#index' do
          expected = { controller: 'notes', action: 'index',
                       contact_id: '1' }
          expect(get: '/contacts/1/notes').to route_to(expected)
        end
        it 'routes to notes#show' do
          expected = { controller: 'notes', action: 'show',
                       contact_id: '1', id: '1' }
          expect(get: '/contacts/1/notes/1').to route_to(expected)
        end
        it 'routes to notes#create' do
          expected = { controller: 'notes', action: 'create',
                       contact_id: '1' }
          expect(post: '/contacts/1/notes').to route_to(expected)
        end
        it 'routes to notes#update via PUT' do
          expected = { controller: 'notes', action: 'update',
                       contact_id: '1', id: '1' }
          expect(put: '/contacts/1/notes/1').to route_to(expected)
        end
        it 'routes to notes#update via PATCH' do
          expected = { controller: 'notes', action: 'update',
                       contact_id: '1', id: '1' }
          expect(patch: '/contacts/1/notes/1').to route_to(expected)
        end
        it 'routes to notes#destroy' do
          expected = { controller: 'notes', action: 'destroy',
                       contact_id: '1', id: '1' }
          expect(delete: '/contacts/1/notes/1').to route_to(expected)
        end
      end
    end
  end
end

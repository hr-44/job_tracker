Rails.application.routes.draw do
  root 'routes#index'

  match '/search_suggestions', to: 'search_suggestions#index', via: :get

  # User accounts, profiles
  get '/register', to: 'users#new'
  resource :profile, controller: 'users', as: 'user', except: :new

  resources :notes,         only: :index
  resources :cover_letters, only: :index, controller: 'job_applications/cover_letters'
  resources :postings,      only: :index, controller: 'job_applications/postings'
  resources :companies,     except: :destroy do
    resources :recruitments, controller: 'recruitments', only: [:new, :create, :destroy]
  end
  resources :categories,    only: :show

  resources :job_applications do
    resources :notes,         except: :index
    resource  :cover_letter,  controller: 'job_applications/cover_letters'
    resource  :posting,       controller: 'job_applications/postings'
  end

  resources :contacts do
    resources :notes, except: :index
  end

  get '/contacts/:contact_id/notes',                 to: 'notes#index'
  get '/job_applications/:job_application_id/notes', to: 'notes#index'
  post '/token', to: 'token#create'
end

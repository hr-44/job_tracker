Rails.application.routes.draw do
  root 'home#index'
  get '/about', to: 'home#about', as: 'about'

  match '/search_suggestions', to: 'search_suggestions#index', via: :get

  # Sessions
  get    '/auth/:provider/callback', to: 'sessions/omni_auth_users#create'
  get    '/auth/failure',            to: 'sessions/omni_auth_users#failure'
  get    'login',                    to: 'sessions/accounts#new'
  post   'login',                    to: 'sessions/accounts#create'
  delete 'logout',                   to: 'sessions/base#destroy'

  # User accounts, profiles
  get '/register', to: 'users#new'
  resource :profile, controller: 'users', as: 'user', except: :new
  get '/profile/edit', to: 'users#edit'

  resources :notes,         only: :index
  resources :cover_letters, only: :index, controller: 'job_applications/cover_letters'
  resources :postings,      only: :index, controller: 'job_applications/postings'

  get '/companies/new', to: 'companies#new'
  get '/companies/:id/edit', to: 'companies#edit'

  resources :companies,     except: :destroy do
    resources :recruitments, controller: 'recruitments', only: [:new, :create, :destroy]
  end
  resources :categories,    only: :show

  get '/job_applications/new', to: 'job_applications#new'
  get '/job_applications/:id/edit', to: 'job_applications#edit'

  resources :job_applications do
    get '/notes/new',   to: 'notes#new'
    get '/notes/:id/edit',  to: 'notes#edit'

    resources :notes,         except: :index
    resource  :cover_letter,  controller: 'job_applications/cover_letters'
    resource  :posting,       controller: 'job_applications/postings'

    get '/cover_letter/new',  to: 'job_applications/cover_letters#new'
    get '/cover_letter/edit', to: 'job_applications/cover_letters#edit'
    get '/posting/new',  to: 'job_applications/postings#new'
    get '/posting/edit', to: 'job_applications/postings#edit'
  end

  get 'contacts/:id/edit', to: 'contacts#edit'
  get 'contacts/new', to: 'contacts#new'

  resources :contacts do
    get '/notes/new',   to: 'notes#new'
    get '/notes/:id/edit',  to: 'notes#edit'

    resources :notes, except: :index
  end
end

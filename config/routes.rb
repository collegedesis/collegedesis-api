Collegedesis::Application.routes.draw do
  root to: 'site#home'

  resources :sessions,                only: [:create, :destroy]
  # Used as API
  resources :organizations,           only: [:index, :show, :create, :update]
  resources :organization_types,      only: [:index, :show]
  resources :users
  resources :memberships,             only: [:index, :show, :destroy]
  resources :membership_applications, only: [:index, :create, :show]
  resources :membership_types,        only: [:index, :show]
  resources :universities,            only: [:index, :show]
  resources :bulletins,               only: [:index, :show, :create]
  resources :comments,                only: [:index, :create]
  resources :votes,                   only: [:index, :create]

  get '/application/:code/approve', to: 'membership_applications#approve'
  get '/application/:code/reject', to: 'membership_applications#reject'

  # Non REST conventions
  match 'info', to: 'site#info'

  # redirect to Ember routes
  match '/news' => redirect('/#/news/')
  match '/contact' => redirect('/#/about/contact')
  match '/store' => redirect('/#/')
  match '/store.php' => redirect('/#/')
  match '/about' => redirect('/#/about')
  match '/join' => redirect('/#/users/signup')
  match '/me' => redirect('/#/users/me')
  match '/directory' => redirect('/#/directory')
end

Rails.application.routes.draw do
  root 'static_pages#home'
  get 'rules' => 'static_pages#rules'
  get 'format' => 'static_pages#format'
  post "/hook" => "tickets#hook"

  get 'password_resets/new'
  get 'password_resets/edit'
  get 'sessions/new'
  get 'password_resets/new'
  get 'password_resets/edit'

  resources :users
  get 'signup'  => 'users#new'
  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'  

  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :tickets, only: [:create]
  resources :tournaments, only: [:index, :show, :update] do
    resources :teams, only: [:index]
    # update_summoners_elo
    # create_balanced_teams
  end
end

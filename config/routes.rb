Rails.application.routes.draw do
  get 'confirmations/update'

  root 'static_pages#home'
  get 'rules' => 'static_pages#rules'
  get 'format' => 'static_pages#format'
  get 'prizing' => 'static_pages#prizing'
  post "/hook" => "tickets#hook"

  get 'password_resets/new'
  get 'password_resets/edit'
  get 'sessions/new'
  get 'password_resets/new'
  get 'password_resets/edit'

  get 'signup'  => 'users#new'
  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy' 

  get 'ticket_reset' => 'tickets#reset_ticket_session'

  resources :users
  resources :series,              only: [:show] do
    resources :series_participations, only: [:index]
  end
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :tickets,             only: [:create]
  resources :tournaments,         only: [:index, :show] do
    member do
      patch 'update_summoners_elo'
      patch 'create_tournament_teams'
      patch 'approve_tournament_teams'
    end
    resources :teams,             only: [:index, :update] do
      resources :tournament_participations,  only: [:update, :create, :index, :destroy]
    end
  end
end

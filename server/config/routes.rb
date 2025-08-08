Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API Routes
  namespace :api do
    namespace :v1 do
      # Authentication endpoints
      resources :sessions, only: [:create, :destroy] do
        collection do
          post :refresh
          get :current
        end
      end

      # Registration endpoint
      resources :registrations, only: [:create]

      # Password management
      resources :passwords, only: [] do
        collection do
          post :forgot
          post :reset
          put :change
        end
      end

      # Protected resources (will be added later)
      resources :accounts, only: [:show, :update]
      resources :users
      resources :roles
      resources :permissions, only: [:index, :show]
    end
  end

  # Root route for API
  root to: proc { [200, {}, ['Powernode API - Version 1.0']] }
end

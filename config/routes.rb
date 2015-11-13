Rails.application.routes.draw do
  resources :calendars do
	  resources :bookings
	end
  get 'calendars/index'

  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  
  resources :pets

  resources :profiles, only: [:show, :edit, :update]
  resources :keeper_users
  resources :services

  root 'home#index'

  get "contact", to: "home#contact"

  get '/regions/:region_id/counties', to: 'counties#index', as: :counties

  namespace :api, defaults: { format: :json } do
    scope module: :v1 do
      #routes
      resources :calendars, only: [:index, :create]
    end
  end
end

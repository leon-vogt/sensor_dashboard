Rails.application.routes.draw do
  root "dashboard#show"
  get  'dashboard',                  to: 'dashboard#show'
  get  'dashboard_charts',           to: 'dashboard#charts'
  get  'dashboard_last_sensor_data', to: 'dashboard#last_sensor_data'

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  resources :users, only: :show
  resource :health_check, only: :show

  resources :devices do
    resource :access_token, only: :create
    resources :api_errors, only: :destroy
    resources :sensors, shallow: true do
      resources :alarm_rules, shallow: true
    end
  end

  namespace :api do
    namespace :v1 do
      resource :sensor_data, only: :create
      resources :mobile_app_connections, only: :create
    end
  end
end

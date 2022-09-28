Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  api_version(:module => "Api::V1", :header => {
    name: "Accept", :value => "application/vnd.providesk; version=1"}) do
      resources :tickets, only: [:create]
      resources :sessions, only: :create
      resources :categories, only: :create
      resources :departments, only: :create
      resources :users, only: [:create, :update, :destroy, :show]
      get '/organizations/:id/departments', to: 'organizations#show_departments' 
  end
end

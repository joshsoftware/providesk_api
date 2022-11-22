require 'sidekiq/web'

Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: "_interslice_session"

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  
  api_version(:module => "Api::V1", :header => {
    name: "Accept", :value => "application/vnd.providesk; version=1"}) do
      resources :tickets, only: [:create, :update, :index]
      resources :sessions, only: :create
      resources :categories, only: :create
      resources :departments, only: :create

      resources :organizations, only: :create
      resources :users, only: :update
      resources :departments do
        member do 
          get 'categories'
          get 'users'
        end
      end
      resources :organizations do
        member do 
          get 'departments'
        end
      end
      resources :tickets do
        member do 
          put 'reopen'
        end
      end
  end
end

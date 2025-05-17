require Rails.root.join("lib", "constraints", "subdomain_constraint")

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")

  constraints(Constraints::SubdomainConstraint.new) do
    # root "barangay/pages#home"
    get "/", to: "barangay/pages#home"
    get "/:page", to: "barangay/pages#show"

    namespace :barangay do
    end

    namespace :admin do
      resources :dashboard, only: [ :index ]
    end
  end

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  root "pages#home"
  get "/:page", to: "pages#show"

  resources :profile, only: [ :edit ]

  namespace :super_admin do
    resources :dashboard, only: [ :index ]
  end
end

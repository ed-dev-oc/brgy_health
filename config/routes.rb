require Rails.root.join("lib", "constraints", "subdomain_constraint")

Rails.application.routes.draw do
  namespace :admin do
    get "users/index"
    get "users/edit"
    get "users/show"
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  mount MissionControl::Jobs::Engine, at: "/jobs"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/") for subdomains
  constraints(Constraints::SubdomainConstraint.new) do
    get "/", to: "barangay/pages#home"

    scope module: "barangay" do
      resources :pages, only: [] do
        get :contact_us, on: :collection
        get :about_us, on: :collection
      end

      resources :announcements, only: [ :index, :show ] do
        resources :appointments, only: [ :create ]
      end

      resources :appointments, only: [ :index ] do
        member do
          patch :flag_as_cancelled
        end
      end
    end
  end

  namespace :admin do
    resources :dashboard, only: [ :index ]
    resources :announcements
    resources :health_programs

    resources :appointments, only: [ :index, :show ] do
      member do
        patch :flag_as_rejected
        patch :flag_as_approved
        post :follow_up_check_up
        patch :flag_as_completed
      end
    end

    resources :cms, only: [ :index, :update ]

    resources :users, only: [ :index, :edit, :update, :create ] do
      member do
        patch :toggle_status
      end
    end

    resources :testimonials, only: [ :create, :update ]

    resources :events, only: [ :index, :create, :update ] do
      member do
        patch :archive
      end
    end
  end


  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }


  root "pages#home"
  get "/:page", to: "pages#show", as: :main_page
  resources :push_subscriptions, only: [ :create ]
  resources :profile, only: [ :edit, :update ]

  namespace :super_admin do
    resources :dashboard, only: [ :index ]

    resources :users, only: [ :index, :show ] do
      member do
        patch :validated
      end
    end

    resources :cms, only: [ :index, :update ]

    resources :barangays, only: [ :index, :show ] do
      member do
        patch :verify
        patch :unverify
      end
    end
  end
end

Rails.application.routes.draw do
  # Devise auth – normal login, no public registration
  devise_for :users, skip: [ :registrations ]

  # Public landing page
  root "landing#index"

  # Public form for beta interest
  resources :beta_requests, only: :create

  # Password change (for first-time tech setup)
  resource :password_change, only: [ :show, :update ]

  # -------------------------------
  # Internal authenticated app
  # -------------------------------
  authenticate :user do
    get "/dashboard", to: "dashboard#show", as: :dashboard
    get "/schedule", to: "schedule#index", as: :schedule

    resources :customers do
      collection do
        post :import # POST /customers/import
        get :export # GET /customers/export
        get :search # GET /customers/search?q=...
      end
    end

    resources :technicians

    resources :jobs do
      member do
        patch :reschedule
      end
      resource :invoice, only: [ :show, :new, :create ]
    end

    resources :invoices, only: [ :index ]

    # Admin panel (only owners/admins)
    namespace :admin do
      get "/", to: "dashboard#show", as: :dashboard
      resource :company, only: [ :edit, :update ]
      resources :users, only: [ :index, :edit, :update ]
    end
  end
end

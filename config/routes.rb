Rails.application.routes.draw do
  # Devise auth – normal login, no public registration
  devise_for :users, skip: [ :registrations ]

  # Public landing page
  root "landing#index"

  # Public form for beta interest
  resources :beta_requests, only: :create

  # -------------------------------
  # Internal authenticated app
  # -------------------------------
  authenticate :user do
    get "/dashboard", to: "dashboard#show", as: :dashboard

    resources :customers
    # resources :jobs
    # resources :invoices
    # resources :technicians  # if you later add this
    # resources :settings, only: [:index, :update] # company settings panel
  end
end

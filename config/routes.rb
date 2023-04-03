Rails.application.routes.draw do
  root "components#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :recipients do
        collection { get :cash_grants }
      end
      resources :filers, :forms, :recipients, only: [:index]
    end
  end
end

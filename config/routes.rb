require "sidekiq/web"

Netbuild::Application.routes.draw do

  devise_for :users,
    path: "accounts", 
    controllers: {
      sessions: "sessions",
      registrations: "registrations"
    }

  constraints subdomain: "www" do
    resources :websites
    resources :themes, only: [:index, :show]
    resources :addons
    post "/webhooks/stripe" => "stripe#webhook", as: :stripe
    get "/webhooks/stripe" => "stripe#webhook" # TESTING
    get "/oauth/callback/stripe" => "stripe#callback"
    
    authenticated :user, lambda { |u| u.super_admin? } do
      mount Sidekiq::Web => "/sidekiq"
    end
  end
  
  constraints subdomain: /.*?/ do
    authenticated do
      resources :blocks, only: [:show, :create]
      
      constraints "1" == "2" do
        scope "/manage" do
          resources :memberships, path: :members
          resources :invoices
          resources :pages
          resources :media
          resources :themes do
            resources :documents
          end
          
          get "/billing" => "invoices#index", as: :billing
          patch "/save" => "websites#update", as: :save
          get "/save", to: redirect { "/manage/theme" }
          get "/:feature" => "websites#edit", as: :manage
        end
      end
      
      get "/manage", to: redirect { "/manage/theme" }
    end
    
    resources :themes, only: :show
    get "/:permalink" => "pages#show", as: :public_page
  end
  
  root to: "pages#show"
  
end

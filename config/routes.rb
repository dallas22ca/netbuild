require "sidekiq/web"

Netbuild::Application.routes.draw do

  devise_for :users, controllers: {
    sessions: "sessions",
    registrations: "registrations"
  }

  constraints subdomain: "www" do
    resources :websites
    resources :themes, only: [:index, :show]
    resources :addons
    post "/stripe" => "stripe#webhook", as: :stripe
    get "/stripe" => "stripe#webhook" # TESTING
    
    authenticated :user, lambda { |u| u.super_admin? } do
      mount Sidekiq::Web => "/sidekiq"
    end
  end
  
  constraints subdomain: /.*?/ do
    authenticated do
      resources :block, only: :show
      
      constraints "1" == "2" do
        scope "/manage" do
          resources :memberships, path: :members
          resources :invoices
          resources :pages
          resources :media
          resources :themes do
            resources :documents
          end
        
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

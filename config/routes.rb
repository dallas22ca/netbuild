Netbuild::Application.routes.draw do
  
  devise_scope :user do
  
    devise_for :users, controllers: {
      sessions: "sessions",
      registrations: "registrations"
    }
    
    authenticated :user do
      resources :websites
      resources :memberships, path: :members, except: :index
      resources :pages
      resources :block, only: :show
      resources :media
      resources :invoices
      
      resources :themes do
        resources :documents
      end
      
      post "/save" => "websites#save", as: :save
    end
    
    constraints subdomain: "www" do
      resources :websites, only: [:new, :create]
      resources :themes, only: [:index, :show]
      resources :addons
      post "/stripe" => "stripe#webhook", as: :stripe
      get "/stripe" => "stripe#webhook" # TESTING
    end
    
    get "/:permalink" => "pages#show", as: :public_page
    root to: "pages#show"

  end
end

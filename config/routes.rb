Netbuild::Application.routes.draw do
  
  devise_scope :user do
  
    constraints subdomain: /^((?!www).)*$/ do
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
        
        resources :themes do
          resources :documents
        end
      end
      
      post "/save" => "websites#save", as: :save
      get "/:permalink" => "pages#show", as: :public_page
      get "/" => "pages#show"
    end
    
    resources :themes, only: [:index, :show]
    resources :websites, only: [:create]
    root "websites#new"

  end
end

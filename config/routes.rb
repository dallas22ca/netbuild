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
      
      resources :themes do
        resources :documents
      end
    end
    
    resources :websites, only: [:new, :create]
    post "/save" => "websites#save", as: :save
    get "/:permalink" => "pages#show", as: :public_page
    root to: "pages#show"

  end
end

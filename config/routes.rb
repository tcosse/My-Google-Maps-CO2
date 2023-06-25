Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root "pages#home"
  patch 'user/:id', to: 'upload_file#attach_file_to_user'
  get 'graph', to: 'pages#graph'
end

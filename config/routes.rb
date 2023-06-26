Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root 'pages#home'
  post 'takeout', to: 'upload_file#process_takeout'
  get 'graph', to: 'pages#graph'
end

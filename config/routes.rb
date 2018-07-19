Rails.application.routes.draw do
  resources :users, except: [:new, :edit, :index]


  #custom route for getting the entries of a specific user
  get '/entries/:user_id', to: 'entries#index', as: 'user_entries'

  #custom route for getting the categories of a specific users
  get 'categories/:user_id', to: 'categories#index', as: 'user_categories'
end

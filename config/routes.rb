Rails.application.routes.draw do
  resources :users, except: [:new, :edit, :index]

  #I used custom routes because you would only ever want to retrieve the categories or entries specific to the current user:

  #custom route for getting the entries of a specific user
  get '/entries/:user_id', to: 'entries#index', as: 'user_entries'

  #custom route for getting the categories of a specific users
  get 'categories/:user_id', to: 'categories#index', as: 'user_categories'


  # Auth Routes
  # scope '/api/v1' do
  #   post '/login', to: 'auth#create'
  #   get '/reauth', to: 'auth#show'
  # end

  namespace :api do
    namespace :v1 do
      post '/login', to: 'auth#create'
      get '/reauth', to: 'auth#show'
    end
  end

end

# TEST FETCH
# data = {"username": "Travis", "password": "1234"}
# options = {
#   method: "POST",
#   headers: {
#     "Content-Type": "application/json",
#     "Accept": "application/json"
#   },
#   body: JSON.stringify(data)
# }
# fetch('http://localhost:3000/api/v1/login', options)

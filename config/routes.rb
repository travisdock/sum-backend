Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      # Auth Routes
      post '/login', to: 'auth#create'
      get '/current_user', to: 'auth#show'

      # Data Routes
      get '/month_category/:user_id', to: 'users#month_category'
      get '/totals_averages/:user_id', to: 'users#totals_averages'

      resources :users, except: [:new, :edit, :index, :show]

      #I used custom routes because you would only ever want to retrieve the categories or entries specific to the current user:

      #custom route for getting the entries of a specific user
      get '/entries/:user_id', to: 'entries#index', as: 'user_entries'
      post '/entries', to: 'entries#create'

      #custom route for getting the categories of a specific users
      get 'categories/:user_id', to: 'categories#index', as: 'user_categories'
    end
  end

end

# TEST LOGIN FETCH
# const data = {"username": "Travis", "password": "1234"};
# const options = {
#   method: "POST",
#   headers: {
#     "Content-Type": "application/json",
#     "Accept": "application/json"
#   },
#   body: JSON.stringify(data)
# };
# fetch('http://localhost:3000/api/v1/login', options)
# .then(resp => resp.json())
# .then(resp => localStorage.current_user = resp)

# TEST DATA FETCH

# const data = {};
# const options = {
#   method: "POST",
#   headers: {
#     "Content-Type": "application/json",
#     "Accept": "application/json"
#   },
#   body: JSON.stringify(data)
# };
# fetch('http://localhost:3000/api/v1/login', options)
# .then(resp => resp.json())

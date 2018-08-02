Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      # Auth Routes
      post '/login', to: 'auth#create'
      get '/current_user', to: 'auth#show'

      # Data Routes
      get '/charts/:user_id', to: 'users#charts'
      get '/entries/:user_id', to: 'users#entries'

      resources :users, except: [:new, :edit, :index, :show]

      #I used custom routes because you would only ever want to retrieve the categories or entries specific to the current user:

      #custom route for getting the entries of a specific user
      post '/entries', to: 'entries#create'
      delete '/entries', to: 'entries#delete'
      patch '/entries', to: 'entries#update'

    end
  end

end

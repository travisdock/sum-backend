Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      # Auth Routes
      post '/login', to: 'auth#create'
      get '/current_user', to: 'auth#show'

      # Data Routes
      get '/charts/:user_id', to: 'users#charts'
      get '/entries/:user_id', to: 'users#entries'

      # User Routes
      resources :users, except: [:new, :edit, :index, :show]

      #custom route for entries
      post '/entries', to: 'entries#create'
      delete '/entries', to: 'entries#delete'
      patch '/entries', to: 'entries#update'
      post '/entries/import', to: 'entries#import'

      # Category Routes
      resources :categories, except: [:new, :edit, :index, :show]

    end
  end

end

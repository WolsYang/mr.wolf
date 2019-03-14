Rails.application.routes.draw do 
  post '/webhook', to: 'chatbot#webhook'
 
  #api
  namespace :api do
    namespace :v1 do
      resources :bargain, only: [:show]
      
        post '/bargain/start', to: 'bargain#index'
        get '/bargain/end', to: 'bargain#game_end'
        get '/bargain/now', to: 'bargain#now_win_bid'

        post '/bargain', to: 'bargain#new_bid'

    end
  end
end


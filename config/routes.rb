Rails.application.routes.draw do 
  post '/webhook', to: 'chatbot#webhook'
 
  #api
  namespace :api do
    namespace :v1 do
      resources :bargain  
        post '/bargain/start', to: 'bargain#index'
        post '/bargain/end', to: 'bargain#game_end'
        post '/bargain/now', to: 'bargain#now_win'
        post '/bargain', to: 'bargain#new_bid'

    end
  end
end


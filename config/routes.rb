Rails.application.routes.draw do 
  post '/webhook', to: 'chatbot#webhook'
 
  #api
  namespace :api do
    namespace :v1 do

        post '/bargain/start', to: 'bargain#index'
        post '/bargain/end', to: 'bargain#game_end'
        post '/bargain/now', to: 'bargain#now_win'
        post '/bargain', to: 'bargain#new_bid'

        get '/counter/index', to: 'counter#index'
        post '/counter/incr', to: 'counter#incr'
        post '/counte/deincr', to: 'counter#deincr'
    end
  end
end


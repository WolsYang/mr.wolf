Rails.application.routes.draw do 
  post '/webhook', to: 'chatbot#webhook'
  
  #scope :path => '/api/v1/', :module => "api_v1", :as => 'v1', :defaults => { :format => :json } do
    get '/bargain', to: 'bargain#index'
    get '/bargain/end', to: 'bargain#game_end'
    get '/bargain/now', to: 'bargain#now_win_bid'

    post '/bargin', to: 'bargain#new_bid'
  #end
end


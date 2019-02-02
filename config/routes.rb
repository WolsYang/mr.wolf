Rails.application.routes.draw do
  devise_for :users
  resources :keyword_mappings
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :push_messages, only: [:new, :create]
  
  get '/eat', to: 'chatbot#eat'
  get '/request_headers', to: 'chatbot#request_headers'
  get '/request_body', to: 'chatbot#request_body'
  get '/response_headers', to: 'chatbot#response_headers'
  get '/response_body', to: 'chatbot#show_response_body'
  get '/sent_request', to: 'chatbot#sent_request'
  
  post '/webhook', to: 'chatbot#webhook'
end


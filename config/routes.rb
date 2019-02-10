Rails.application.routes.draw do |
|  
  post '/webhook', to: 'chatbot#webhook'
  
end


Cangaroo::Engine.routes.draw do

  resources :endpoint, constraints: { format: :json }
end

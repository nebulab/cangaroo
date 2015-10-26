Cangaroo::Engine.routes.draw do

  resources :endpoint, only: [:create], constraints: { format: :json }
end

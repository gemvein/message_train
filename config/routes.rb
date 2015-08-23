MessageTrain::Engine.routes.draw do
  authenticated MessageTrain.configuration.user_route_authentication_method do
    resources :boxes, path: 'box', param: :division, only: [:show, :update, :destroy] do
      resources :conversations, only: [:show, :update, :destroy]
      resources :messages, except: [:index, :destroy]
      resources :participants, only: [:index, :show]
    end
  end

  match '/box(/*path)', to: redirect(MessageTrain.configuration.user_sign_in_path), via: [:get, :put, :delete]
end

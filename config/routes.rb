NightTrain::Engine.routes.draw do
  resources :boxes, path: 'box', param: :division, only: [:show, :update, :destroy] do
    resources :conversations
  end
end

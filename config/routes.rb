MessageTrain::Engine.routes.draw do
  concern :boxable do
    resources(
      :boxes,
      path: 'box',
      param: :division,
      only: [:show, :update, :destroy]
    ) do
      resources :conversations, only: [:show, :update, :destroy]
      resources :messages, except: [:index, :destroy]
      get(
        'participants/:model',
        as: :model_participants,
        to: 'participants#index'
      )
      get(
        'participants/:model/:id',
        as: :model_participant,
        to: 'participants#show'
      )
    end
  end

  authenticated MessageTrain.configuration.user_route_authentication_method do
    concerns :boxable
    resources :collectives, as: :collective, only: [], concerns: :boxable
    post 'unsubscribes/all', to: 'unsubscribes#create', all: true
    delete 'unsubscribes/all', to: 'unsubscribes#destroy', all: true
    resources :unsubscribes, only: [:index, :create, :destroy]
  end

  match(
    '/box(/*path)',
    to: 'boxes#redirect_to_sign_in',
    via: [:get, :put, :post, :delete]
  )

  match(
    '/collectives(/*path)',
    to: 'boxes#redirect_to_sign_in',
    via: [:get, :put, :post, :delete]
  )

  match(
    '/unsubscribes(/*path)',
    to: 'unsubscribes#redirect_to_sign_in',
    via: [:get, :put, :post, :delete]
  )
end

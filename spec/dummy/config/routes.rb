Rails.application.routes.draw do
  mount MessageTrain::Engine => '/messages', as: 'message_train'
  devise_for :users
end

Rails.application.routes.draw do
  mount MessageTrain::Engine => '/', as: 'message_train'
  devise_for :users
end

Rails.application.routes.draw do

  devise_for :users
  mount NightTrain::Engine => "/night_train"
end

Rails.application.routes.draw do

  
  
  mount NightTrain::Engine => '/box', :as => 'night_train'
  devise_for :users
end

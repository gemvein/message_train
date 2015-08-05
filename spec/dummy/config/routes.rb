Rails.application.routes.draw do

	mount NightTrain::Engine => '/', :as => 'night_train'
  devise_for :users
end

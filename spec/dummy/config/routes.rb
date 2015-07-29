Rails.application.routes.draw do
  
  authenticated :user do
		mount NightTrain::Engine => '/', :as => 'night_train'
	end
  devise_for :users
end

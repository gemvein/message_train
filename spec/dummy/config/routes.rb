Rails.application.routes.draw do

  
  
  
  authenticated :user do
		mount MessageTrain::Engine => '/', :as => 'message_train'
	end
  devise_for :users
end

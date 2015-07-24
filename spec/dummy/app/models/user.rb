class User < ActiveRecord::Base
  # Rolify Gem
  rolify

  # FriendlyId Gem
  extend FriendlyId
  friendly_id :display_name, use: :slugged

  # Devise Gem
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # NightTrain Gem
  night_train name_column: :slug, friendly_id: true
end

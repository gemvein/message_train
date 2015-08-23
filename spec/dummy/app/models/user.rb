require 'group' #TODO This is a hack to get the group model to load in production. Works, but for how long?

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

  # MessageTrain Gem
  message_train slug_column: :slug, name_column: :display_name

  def contacts
    User.all + Group.all
  end
end
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
  message_train(
    name_column: :display_name,
    address_book_method: :valid_recipients_for
  )

  def self.valid_recipients_for(_sender)
    all
  end
end

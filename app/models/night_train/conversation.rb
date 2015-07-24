module NightTrain
  class Conversation < ActiveRecord::Base
    has_many :messages
    has_many :ignores
  end
end

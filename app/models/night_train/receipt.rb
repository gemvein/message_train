module NightTrain
  class Receipt < ActiveRecord::Base
    belongs_to :recipient, polymorphic: true
    belongs_to :message
    validates_presence_of :recipient, :message
  end
end

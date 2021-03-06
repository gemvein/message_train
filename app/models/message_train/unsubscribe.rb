module MessageTrain
  # Unsubscribe model
  class Unsubscribe < ActiveRecord::Base
    belongs_to :recipient, polymorphic: true
    belongs_to :from, polymorphic: true
    validates_presence_of :recipient
  end
end

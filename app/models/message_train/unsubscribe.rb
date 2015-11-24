module MessageTrain
  class Unsubscribe < ActiveRecord::Base
    belongs_to :recipient, polymorphic: true
    belongs_to :from, polymorphic: true
  end
end

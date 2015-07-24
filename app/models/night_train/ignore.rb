module NightTrain
  class Ignore < ActiveRecord::Base
    belongs_to :recipient, polymorphic: true
    belongs_to :conversation
  end
end

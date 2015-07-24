module NightTrain
  class Ignore < ActiveRecord::Base
    belongs_to :recipient, polymorphic: true
    belongs_to :conversation

    def self.find_by_recipient(recipient)
      where('recipient_type = ? AND recipient_id = ?', recipient.class.name, recipient.id).first
    end
  end
end

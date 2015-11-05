module MessageTrain
  class Ignore < ActiveRecord::Base
    belongs_to :participant, polymorphic: true
    belongs_to :conversation

    validates_presence_of :conversation, :participant

    scope :find_all_by_participant, ->(participant) { where(participant: participant) }

    def self.conversations
      MessageTrain::Conversation.joins(:ignores).where(message_train_ignores: { id: where(nil) })
    end
  end
end

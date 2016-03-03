module MessageTrain
  # Ignore model
  class Ignore < ActiveRecord::Base
    belongs_to :participant, polymorphic: true
    belongs_to(
      :conversation,
      foreign_key: :message_train_conversation_id,
      touch: true
    )

    validates_presence_of :conversation, :participant

    scope :find_all_by_participant, (lambda do |participant|
      where(participant: participant)
    end)

    def self.conversations
      MessageTrain::Conversation.joins(:ignores)
                                .where(
                                  message_train_ignores: { id: where(nil) }
                                )
    end
  end
end

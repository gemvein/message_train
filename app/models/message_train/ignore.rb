module MessageTrain
  class Ignore < ActiveRecord::Base
    belongs_to :participant, polymorphic: true
    belongs_to :conversation

    validates_presence_of :conversation, :participant

    scope :find_all_by_participant, ->(participant) { where('participant_type = ? AND participant_id = ?', participant.class.name, participant.id) }

    def self.conversation_ids
      all.collect { |y| y.conversation_id }
    end

    def self.conversations
      MessageTrain::Conversation.where('id IN (?)', conversation_ids )
    end
  end
end

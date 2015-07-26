module NightTrain
  class Ignore < ActiveRecord::Base
    belongs_to :participant, polymorphic: true
    belongs_to :conversation

    scope :find_all_by_participant, ->(participant) { where('participant_type = ? AND participant_id = ?', participant.class.name, participant.id) }

    def self.conversation_ids
      all.collect { |y| y.conversation.id }
    end

    def self.conversations
      where('id IN (?)', conversation_ids )
    end
  end
end

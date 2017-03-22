module MessageTrain
  # Ignore model
  class Ignore < ActiveRecord::Base
    IGNORE_METHODS = {
      'Hash' => :ignore_hash,
      'Array' => :ignore_array,
      'String' => :ignore_id,
      'Fixnum' => :ignore_id,
      'MessageTrain::Conversation' => :ignore_conversation
    }.freeze

    UNIGNORE_METHODS = {
      'Hash' => :unignore_hash,
      'Array' => :unignore_array,
      'String' => :unignore_id,
      'Fixnum' => :unignore_id,
      'MessageTrain::Conversation' => :unignore_conversation
    }.freeze

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

    scope :conversations, (lambda do
      MessageTrain::Conversation.joins(:ignores)
        .where(message_train_ignores: { id: where(nil) })
    end)

    def self.ignore(object, box)
      method = IGNORE_METHODS[object.class.name]
      return ignoring_error(object, box) if method.nil?
      send(method, object, box)
    end

    def self.unignore(object, box)
      method = UNIGNORE_METHODS[object.class.name]
      return unignoring_error(object, box) if method.nil?
      send(method, object, box)
    end

    def self.ignore_hash(object, box)
      ignore object.values, box
    end

    def self.ignore_array(object, box)
      object.collect { |item| ignore(item, box) }.uniq == [true]
    end

    def self.ignore_id(object, box)
      ignore(box.find_conversation(object.to_i), box)
    end

    def self.ignore_conversation(object, box)
      if box.authorize(object)
        object.participant_ignore(box.participant)
        box.results.add(object, :update_successful.l)
      else
        false
      end
    end

    def self.ignoring_error(object, box)
      box.errors.add(self, :cannot_ignore_type.l(type: object.class.name))
      object
    end

    def self.unignore_hash(object, box)
      unignore object.values, box
    end

    def self.unignore_array(object, box)
      object.collect { |item| unignore(item, box) }.uniq == [true]
    end

    def self.unignore_id(object, box)
      unignore(box.find_conversation(object.to_i), box)
    end

    def self.unignore_conversation(object, box)
      if box.authorize(object)
        object.participant_unignore(box.participant)
        box.results.add(object, :update_successful.l)
        object
      else
        false
      end
    end

    def self.unignoring_error(object, box)
      box.errors.add(self, :cannot_unignore_type.l(type: object.class.name))
      object
    end
  end
end

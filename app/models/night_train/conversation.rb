module NightTrain
  class Conversation < ActiveRecord::Base
    has_many :messages
    has_many :ignores

    def set_ignored_by(recipient)
      ignores.first_or_create!(recipient: recipient)
    end

    def is_ignored_by?(recipient)
      !ignores.find_by_recipient(recipient).nil?
    end
  end
end
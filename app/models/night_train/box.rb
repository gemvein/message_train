module NightTrain
  class Box
    attr_accessor :parent
    def initialize(parent)
      @parent = parent
    end
    def conversations(options = {})
      found = parent.conversations(options[:division]).with_undeleted_for(parent)
      if options[:read] == false || options[:unread]
        found = found.with_unread_for(parent)
      end
      if options[:division] == :trash
        found = found.with_trashed_for(parent)
      elsif options[:division] == :trash_and_all
      else
        found = found.with_untrashed_for(parent)
      end
      found
    end
  end
end

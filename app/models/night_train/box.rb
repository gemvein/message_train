module NightTrain
  class Box
    attr_accessor :parent
    def initialize(parent)
      @parent = parent
    end
    def conversations(options = {})
      found = parent.conversations(options[:division])
      if options[:read] == false || options[:unread]
        found = found.unread(messageable)
      end
      found
    end
  end
end

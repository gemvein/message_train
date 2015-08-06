module NightTrain
  class Box
    include ActiveModel::Model
    attr_accessor :parent, :division, :errors, :results
    alias_method :id, :division

    def initialize(parent, division)
      @parent = parent
      @division = division
      @results = Results.new(self)
      @errors = Errors.new(self)
    end

    def marks
      { conversations: nil }
    end

    def to_param
      division.to_s
    end

    def unread_count
      conversations(unread: true).count
    end

    def conversations(options = {})
      found = parent.conversations(division).with_undeleted_for(parent)
      if options[:read] == false || options[:unread]
        found = found.with_unread_for(parent)
      end
      if division == :trash
        found = found.with_trashed_for(parent)
      else
        found = found.with_untrashed_for(parent)
        if division == :drafts
          found = found.with_drafts_by(parent)
        else
          found = found.with_ready_for(parent)
        end
        if division == :ignored
          found = found.ignored(parent)
        else
          found = found.unignored(parent)
        end
      end
      found
    end

    def find_conversation(id)
      parent.all_conversations.find(id)
    end

    def find_message(id)
      parent.all_messages.find(id)
    end

    def ignore(object)
      case object.class.name
        when 'Hash'
          ignore object.values
        when 'Array'
          object.collect { |item| ignore(item) }.uniq == [true]
        when 'String', 'Fixnum'
          id = object.to_i
          object = parent.all_conversations.find_by_id(id)
          if object.nil?
            errors.add(self, :class_id_not_found_in_box.l(class: 'Conversation', id: id.to_s))
          else
            ignore(object)
          end
        when 'NightTrain::Conversation'
          if authorize(object)
            if object.set_ignored(parent)
              results.add(object, :update_successful.l)
            else
              errors.add(object, object.errors.full_messages.to_sentence)
            end
          else
            false
          end
        else
        errors.add(self, :cannot_ignore_type.l(type: object.class.name))
      end
    end

    def unignore(object)
      case object.class.name
        when 'Hash'
          unignore object.values
        when 'Array'
          object.collect { |item| unignore(item) }.uniq == [true]
        when 'String', 'Fixnum'
          id = object.to_i
          object = parent.all_conversations.find_by_id(id)
          if object.nil?
            errors.add(self, :class_id_not_found_in_box.l(class: 'Conversation', id: id.to_s))
          else
            unignore(object)
          end
        when 'NightTrain::Conversation'
          if authorize(object)
            if object.set_unignored(parent)
              results.add(object, :update_successful.l)
            else
              errors.add(object, object.errors.full_messages.to_sentence)
            end
          else
            false
          end
        else
        errors.add(self, :cannot_ignore_type.l(type: object.class.name))
      end
    end

    def title
      "box_title_#{division.to_s}".to_sym.l
    end

    def message
      if !errors.all.empty?
        errors.all.collect { |x| x[:message] }.uniq.to_sentence
      elsif results.all.empty?
        :nothing_to_do.l
      else
        results.all.collect { |x| x[:message] }.uniq.to_sentence
      end
    end

    def mark(mark_to_set, objects)
      objects.each do |key, object|
        if object.present?
          case object.class.name
            when 'Hash'
              mark(mark_to_set, { key => object.values } )
            when 'Array'
              object.collect { |item| mark(mark_to_set, key => item) }.uniq == [true]
            when 'String', 'Fixnum'
              id = object.to_i
              object = parent.send("all_#{key}".to_sym).find_by_id(id)
              if object.nil?
                errors.add(self, :class_id_not_found_in_box.l(class: key.to_s.classify, id: id.to_s))
              else
                mark(mark_to_set, key => object)
              end
            when 'NightTrain::Conversation', 'NightTrain::Message'
              if authorize(object)
                if object.mark(mark_to_set, parent)
                  results.add(object, :update_successful.l)
                else
                  errors.add(object, object.errors.full_messages.to_sentence)
                end
              else
                false
              end
            else
            errors.add(self, :cannot_mark_type.l(type: object.class.name))
          end
        end
      end
    end

    def authorize(object)
      case object.class.name
        when 'NightTrain::Conversation'
          if object.includes_receipts_for? parent
            true
          else
            errors.add(object, :access_to_conversation_id_denied.l(id: object.id))
          end
        when 'NightTrain::Message'
          if object.receipts.for(parent).any?
            true
          else
            errors.add(object, :access_to_message_id_denied.l(id: object.id))
          end
        else
          errors.add(object, :dont_know_how_to_mark_object.l(object: object.class.name))
      end
    end

    class Results
      attr_accessor :items, :box

      def initialize(box)
        @items = []
        @box = box
      end

      def add(object, message)
        item = {}
        if object.is_a? NightTrain::Box
          item[:css_id] = 'box'
          item[:path] = NightTrain::Engine.routes.path_for({
                                                             controller: 'night_train/boxes',
                                                             action: :show,
                                                             division: object.division
                                                         })
        else
          item[:css_id] = "#{object.class.table_name.singularize}_#{object.id.to_s}"
          item[:path] = NightTrain::Engine.routes.path_for({
                                                             controller: object.class.table_name.gsub('night_train_', 'night_train/'),
                                                             action: :show,
                                                             box_division: box.division,
                                                             id: object.id
                                                         })
        end
        item[:message] = message
        items << item
        true
      end

      def all
        items
      end
    end
    class Errors < Results
      def add(object, message)
        super object, message
        false
      end
    end
  end
end

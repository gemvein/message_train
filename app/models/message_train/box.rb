module MessageTrain
  class Box
    include ActiveModel::Model
    attr_accessor :parent, :division, :participant, :errors, :results
    alias_method :id, :division

    def initialize(parent, division, participant = nil)
      @parent = parent
      @participant = participant || parent
      @division = division
      @results = Results.new(self)
      @errors = Errors.new(self)
    end

    def to_param
      division.to_s
    end

    def unread_count
      conversations(unread: true).count
    end

    def conversations(options = {})
      found = parent.conversations(division, participant)
      found = found.with_undeleted_for(participant)
      if options[:read] == false || options[:unread]
        found = found.with_unread_for(participant)
      end
      if division == :trash
        found = found.with_trashed_for(participant)
      else
        found = found.with_untrashed_for(participant)
        if division == :drafts
          found = found.with_drafts_by(participant)
        else
          found = found.with_ready_for(participant)
        end
        if division == :ignored
          found = found.ignored(participant)
        else
          found = found.unignored(participant)
        end
      end
      found
    end

    def find_conversation(id)
      parent.all_conversations(participant).find(id)
    end

    def find_message(id)
      parent.all_messages(participant).find(id)
    end

    def new_message(args = {})
      if args[:conversation_id].nil?
        message = MessageTrain::Message.new(args)
      else
        conversation = find_conversation(args[:conversation_id])
        previous_message = conversation.messages.last
        message = conversation.messages.build(args)
        message.subject = "Re: #{conversation.subject}"
        message.body = "<blockquote>#{previous_message.body}</blockquote><p>&nbsp;</p>"
        recipient_arrays = {}
        conversation.default_recipients_for(parent).each do |recipient|
          table_name = recipient.class.table_name
          recipient_arrays[table_name] ||= []
          recipient_arrays[table_name] << recipient.send(MessageTrain.configuration.slug_columns[table_name.to_sym])
        end
        recipient_arrays.each do |key, array|
          message.recipients_to_save[key] = array.join(', ')
        end
      end
      message
    end

    def send_message(attributes)
      message_to_send = MessageTrain::Message.new attributes
      message_to_send.sender = participant
      unless parent.valid_senders.include? participant
        errors.add(message_to_send, :invalid_sender_for_thing.l(thing: "#{parent.class.name} #{parent.id}"))
        return false
      end
      if message_to_send.save
        if message_to_send.draft
          results.add(message_to_send, :message_saved_as_draft.l)
        else
          results.add(message_to_send, :message_sent.l)
        end
      else
        errors.add(message_to_send, message_to_send.errors.full_messages.to_sentence)
      end
      message_to_send
    end

    def update_message(message_to_update, attributes)
      attributes.delete(:sender)
      if message_to_update.sender == participant && parent.valid_senders.include?(participant)
        message_to_update.update(attributes)
        message_to_update.reload
        if message_to_update.errors.empty?
          if message_to_update.draft
            results.add(message_to_update, :message_saved_as_draft.l)
          else
            results.add(message_to_update, :message_sent.l)
          end
        else
          errors.add(message_to_update, message_to_update.errors.full_messages.to_sentence)
        end
        message_to_update
      else
        errors.add(message_to_update, :access_to_message_id_denied.l(id: message_to_update.id))
        false
      end
    end

    def ignore(object)
      case object.class.name
        when 'Hash'
          ignore object.values
        when 'Array'
          object.collect { |item| ignore(item) }.uniq == [true]
        when 'String', 'Fixnum'
          id = object.to_i
          object = find_conversation(id)
          if object.nil?
            errors.add(self, :class_id_not_found_in_box.l(class: 'Conversation', id: id.to_s))
          else
            ignore(object)
          end
        when 'MessageTrain::Conversation'
          if authorize(object)
            if object.set_ignored(participant)
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
          object = find_conversation(id)
          if object.nil?
            errors.add(self, :class_id_not_found_in_box.l(class: 'Conversation', id: id.to_s))
          else
            unignore(object)
          end
        when 'MessageTrain::Conversation'
          if authorize(object)
            if object.set_unignored(participant)
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
              object = parent.send("all_#{key}".to_sym, participant).find_by_id(id)
              if object.nil?
                errors.add(self, :class_id_not_found_in_box.l(class: key.to_s.classify, id: id.to_s))
              else
                mark(mark_to_set, key => object)
              end
            when 'MessageTrain::Conversation', 'MessageTrain::Message'
              if authorize(object)
                if object.mark(mark_to_set, participant)
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
        when 'MessageTrain::Conversation'
          if object.includes_receipts_for? participant
            true
          else
            errors.add(object, :access_to_conversation_id_denied.l(id: object.id))
          end
        when 'MessageTrain::Message'
          if object.receipts.for(participant).any?
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
        if object.is_a? MessageTrain::Box
          item[:css_id] = 'box'
          route_args = {
              controller: 'message_train/boxes',
              action: :show,
              division: object.division
          }
          if box.parent != box.participant
            collective = box.parent
            table_part = collective.class.table_name
            slug_part = collective.send(MessageTrain.configuration.slug_columns[collective.class.table_name.to_sym])
            route_args[:collective_id] = "#{table_part}:#{slug_part}"
          end
          item[:path] = MessageTrain::Engine.routes.path_for(route_args)
        elsif object.new_record?
          item[:css_id] = "#{object.class.table_name.singularize}"
          item[:path] = nil
        else
          item[:css_id] = "#{object.class.table_name.singularize}_#{object.id.to_s}"
          route_args = {
              controller: object.class.table_name.gsub('message_train_', 'message_train/'),
              action: :show,
              box_division: box.division,
              id: object.id
          }
          if box.parent != box.participant
            collective = box.parent
            table_part = collective.class.table_name
            slug_part = collective.send(MessageTrain.configuration.slug_columns[collective.class.table_name.to_sym])
            route_args[:collective_id] = "#{table_part}:#{slug_part}"
          end
          item[:path] = MessageTrain::Engine.routes.path_for(route_args)
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

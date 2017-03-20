module MessageTrain
  # Box model
  class Box
    include ActiveModel::Model
    attr_accessor :parent, :division, :participant, :errors, :results
    alias id division

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
      found = conversations(unread: true)
      found.count
    end

    def conversations(options = {})
      found = parent.conversations(division, participant)
      found = found.with_undeleted_for(participant)
      if options[:read] == false || options[:unread]
        found = found.with_unread_for(participant)
      end
      found
    end

    def find_conversation(id)
      parent.all_conversations(participant).find(id)
    end

    def find_message(id)
      parent.all_messages(participant).find(id)
    end

    def send_message(attributes)
      message = MessageTrain::Message.new attributes
      return false unless authorize_send_message(message)
      message.sender = participant
      return message_send_error(message) unless message.save
      message_send_success(message)
    end

    def message_send_error(message)
      errors.add(message, message.errors.full_messages.to_sentence)
      message
    end

    def message_send_success(message)
      if message.draft
        results.add(message, :message_saved_as_draft.l)
      else
        results.add(message, :message_sent.l)
      end
      message
    end

    def authorize_send_message(message)
      unless parent.valid_senders.include? participant
        errors.add(
          message,
          :invalid_sender_for_thing.l(
            thing: "#{parent.class.name} #{parent.id}"
          )
        )
        return false
      end
      true
    end

    def update_message(message, attributes)
      !message.draft && raise(ActiveRecord::RecordNotFound)
      attributes.delete(:sender)
      return false unless authorize_update_message(message)
      message.update(attributes)
      message.reload
      return message_update_error(message) if message.errors.any?
      message_update_success(message)
    end

    def message_update_success(message)
      if message.draft
        results.add(message, :message_saved_as_draft.l)
      else
        results.add(message, :message_sent.l)
      end
      message
    end

    def message_update_error(message)
      errors.add(message, message.errors.full_messages.to_sentence)
      message
    end

    def authorize_update_message(message)
      unless message.sender == participant &&
             parent.valid_senders.include?(participant)
        return message_access_denied(message)
      end
      true
    end

    def message_access_denied(message)
      errors.add(message, :access_to_message_id_denied.l(id: message.id))
      false
    end

    def title
      "box_title_#{division}".to_sym.l
    end

    def message
      what_happened = errors.any? ? errors : results
      return :nothing_to_do.l unless what_happened.any?
      what_happened.all.map { |x| x[:message] }.uniq.to_sentence
    end

    def mark(mark_to_set, objects)
      objects.each do |key, object|
        next unless object.present? # Allow skipping empty objects
        unless key.to_s =~ /^(conversations|messages)$/
          errors.add(self, :cannot_mark_type.l(type: key.to_s))
          next
        end
        mark_object mark_to_set, key, object
      end
    end

    def mark_hash(mark_to_set, key, object)
      mark(mark_to_set, key => object.values)
    end

    def mark_array(mark_to_set, key, object)
      object.collect { |item| mark(mark_to_set, key => item) }
            .uniq == [true]
    end

    def mark_id(mark_to_set, key, object)
      model = "MessageTrain::#{key.to_s.classify}".constantize
      mark_communication(mark_to_set, model.find_by_id!(object.to_i))
    end

    def mark_communication(mark_to_set, object)
      return unless authorize(object)
      object.mark(mark_to_set, participant)
      results.add(object, :update_successful.l)
    end

    def marking_error(object)
      errors.add(
        self,
        :cannot_mark_with_data_type.l(data_type: object.class.name)
      )
      object
    end

    def mark_object(mark_to_set, key, object)
      case object.class.name
      when 'Hash'
        mark_hash(mark_to_set, key, object)
      when 'Array'
        mark_array(mark_to_set, key, object)
      when 'String', 'Fixnum'
        mark_id(mark_to_set, key, object)
      when 'MessageTrain::Conversation', 'MessageTrain::Message'
        mark_communication(mark_to_set, object) # Doesn't need key
      else
        marking_error(object)
      end
    end

    def authorize(object)
      case object.class.name
      when 'MessageTrain::Conversation'
        authorize_conversation(object)
      when 'MessageTrain::Message'
        authorize_message(object)
      else
        errors.add(object, :cannot_authorize_type.l(type: object.class.name))
      end
    end

    def authorize_conversation(object)
      object.includes_receipts_for?(participant) ||
        errors.add(object, :access_to_conversation_id_denied.l(id: object.id))
    end

    def authorize_message(object)
      object.receipts.for(participant).any? ||
        errors.add(object, :access_to_message_id_denied.l(id: object.id))
    end

    # Box::Results class
    class Results
      attr_accessor :items, :box

      def initialize(box)
        @items = []
        @box = box
      end

      def add(object, message)
        items << case object.class.name
                 when 'MessageTrain::Box'
                   result_for_box(object, message)
                 when 'MessageTrain::Conversation', 'MessageTrain::Message'
                   result_for_communication(object, message)
                 else
                   result_for_misc_object(object, message)
                 end
        true
      end

      def result_for_misc_object(object, message)
        {
          css_id: object.class.name.singularize.downcase,
          path: nil,
          message: message
        }
      end

      def result_for_communication(object, message)
        table_name = object.class.table_name
        item = {
          message: message,
          css_id: table_name.singularize,
          path: nil
        }
        return item if object.new_record?
        item[:css_id] += "_#{object.id}"
        route_args = {
          controller: table_name.gsub('message_train_', 'message_train/'),
          action: :show,
          box_division: box.division,
          id: object.id,
          collective_id: collective_id_for_box(box)
        }
        item[:path] = MessageTrain::Engine.routes.path_for(route_args)
        item
      end

      def result_for_box(object, message)
        item = {
          css_id: 'box',
          message: message
        }
        route_args = {
          controller: 'message_train/boxes',
          action: :show,
          division: object.division,
          collective_id: collective_id_for_box(box)
        }
        item[:path] = MessageTrain::Engine.routes.path_for(route_args)
        item
      end

      def collective_id_for_box(box)
        return if box.parent == box.participant
        collective = box.parent
        table_part = collective.class.table_name
        slug_part = collective.send(
          MessageTrain.configuration.slug_columns[
            collective.class.table_name.to_sym
          ]
        )
        "#{table_part}:#{slug_part}"
      end

      def all
        items
      end

      def any?
        items.any?
      end
    end
    # Box::Errors class
    class Errors < Results
      def add(object, message)
        super object, message
        false
      end
    end
  end
end

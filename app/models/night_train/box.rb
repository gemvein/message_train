module NightTrain
  class Box
    include ActiveModel::Model
    attr_accessor :parent, :division, :errors, :results

    def initialize(parent, division)
      @parent = parent
      @division = division
      @errors = {}
      @results = {}
    end

    def to_param
      division.to_s
    end

    def unread_count
      conversations(unread: true).count
    end

    def conversations(options = {})
      found = parent.conversations(division).unignored(parent).with_undeleted_for(parent)
      if options[:read] == false || options[:unread]
        found = found.with_unread_for(parent)
      end
      case division
        when :trash
          found = found.with_trashed_for(parent)
        when :drafts
          found = found.with_drafts_by(parent)
        else
          found = found.with_ready_for(parent).with_untrashed_for(parent)
      end
      found
    end

    def ignore(object)
      case object.class.name
        when 'Array'
          object.collect { |item| ignore(item) }.uniq == [true]
        when 'String', 'Integer'
          id = object.to_i
          object = parent.all_conversations.find_by_id(id)
          if object.nil?
            errors['conversations'] = :class_id_not_found_in_box.l(class: 'Conversation', id: id.to_s)
          else
            ignore(object)
          end
        when 'NightTrain::Conversation'
          css_id = "conversation_#{object.id.to_s}"
          if authorize(object)
            if object.set_ignored(parent)
              results[css_id] = :update_successful.l
              true
            else
              errors[css_id] = object.errors.full_messages.to_sentence
              false
            end
          else
            false
          end
        else
        errors['box'] = :cannot_ignore_type.l(type: object.class.name)
        false
      end
    end

    def unignore(object)
      case object.class.name
        when 'Array'
          object.collect { |item| unignore(item) }.uniq == [true]
        when 'String', 'Integer'
          id = object.to_i
          object = parent.all_conversations.find_by_id(id)
          if object.nil?
            errors['conversations'] = :class_id_not_found_in_box.l(class: 'Conversation', id: id.to_s)
          else
            unignore(object)
          end
        when 'NightTrain::Conversation'
          css_id = "conversation_#{object.id.to_s}"
          if authorize(object)
            if object.set_unignored(parent)
              results[css_id] = :update_successful.l
              true
            else
              errors[css_id] = object.errors.full_messages.to_sentence
              false
            end
          else
            false
          end
        else
          errors['box'] = :cannot_ignore_type.l(type: object.class.name)
          false
      end
    end

    def title
      "box_title_#{division.to_s}".to_sym.l
    end

    def mark(mark_to_set, objects)
      objects.each do |key, object|
        case object.class.name
          when 'Array'
            object.collect { |item| mark(mark_to_set, key => item) }.uniq == [true]
          when 'String', 'Integer'
            id = object.to_i
            object = parent.send("all_#{key}".to_sym).find_by_id(id)
            if object.nil?
              errors[key] = :class_id_not_found_in_box.l(class: key.to_s.classify, id: id.to_s)
            else
              mark(mark_to_set, key => object)
            end
          when 'NightTrain::Conversation', 'NightTrain::Message'
            css_id = "#{object.class.table_name.singularize}_#{object.id.to_s}"
            if authorize(object)
              if object.mark(mark_to_set, parent)
                results[css_id] = :update_successful.l
                true
              else
                errors[css_id] = object.errors.full_messages.to_sentence
                false
              end
            else
              false
            end
          else
          errors['box'] = :cannot_mark_type.l(type: object.class.name)
          false
        end
      end
    end

    def authorize(object)
      css_id = "#{object.class.table_name.singularize}_#{object.id.to_s}"
      case object.class.name
        when 'NightTrain::Conversation'
          unless object.includes_receipts_for? parent
            errors[css_id] =  :access_to_conversation_id_denied.l(id: object.id)
            return false
          end
        when 'NightTrain::Message'
          unless object.receipts.for?(parent).any?
            errors[css_id] = :access_to_message_id_denied.l(id: object.id)
            return false
          end
        else
          errors[css_id] = :dont_know_how_to_mark_object.l(object: object.class.name)
          return false
      end
      errors.empty?
    end
  end
end

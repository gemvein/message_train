module MessageTrain
  module MessagesHelper
    def message_class(box, message)
      css_classes = []

      if message.is_unread_for?(@box_user)
        css_classes << 'unread panel-info'
      else
        css_classes << 'read'
      end

      if message.draft
        css_classes << 'draft'
      end

      if box.division == :trash
        unless message.is_trashed_for?(@box_user)
          css_classes << 'hide'
        end
      else
        unless message.is_untrashed_for?(@box_user)
          css_classes << 'hide'
        end
      end
      css_classes.join(' ')
    end

    def message_trashed_toggle(message)
      render partial: 'message_train/messages/trashed_toggle', locals: { message: message }
    end

    def message_read_toggle(message)
      render partial: 'message_train/messages/read_toggle', locals: { message: message }
    end

    def message_deleted_toggle(message)
      render partial: 'message_train/messages/deleted_toggle', locals: { message: message }
    end

    def message_recipients(message)
      message.recipients.collect { |x| box_participant_name(x) }.to_sentence
    end

  private

    def message_toggle(message, icon, mark_to_set, title, options = {})
      options[:remote] = true
      options[:id] = "mark_#{mark_to_set}_#{message.id}"
      options[:class] = "mark-link"
      options[:method] = :put
      options[:title] = title
      render partial: 'message_train/messages/toggle', locals: {
                                                         message: message,
                                                         icon: icon,
                                                         mark_to_set: mark_to_set,
                                                         options: options
                                                     }
    end
  end
end

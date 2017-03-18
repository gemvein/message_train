module MessageTrain
  # Messages helper
  module MessagesHelper
    def message_class(box, message)
      css_classes = []
      css_classes << message_css_for_read_state(message)
      css_classes << message_css_for_draft_state(message)
      css_classes << message_css_for_hide_state(box, message)
      css_classes.join(' ')
    end

    def message_trashed_toggle(message)
      render(
        partial: 'message_train/messages/trashed_toggle',
        locals: { message: message }
      )
    end

    def message_read_toggle(message)
      render(
        partial: 'message_train/messages/read_toggle',
        locals: { message: message }
      )
    end

    def message_deleted_toggle(message)
      render(
        partial: 'message_train/messages/deleted_toggle',
        locals: { message: message }
      )
    end

    def message_recipients(message)
      message.recipients.collect { |x| box_participant_name(x) }.to_sentence
    end

    private

    def message_toggle(message, icon, mark_to_set, title, options = {})
      options[:remote] = true
      options[:id] = "mark_#{mark_to_set}_#{message.id}"
      options[:class] = 'mark-link'
      options[:method] = :put
      options[:title] = title
      render(
        partial: 'message_train/messages/toggle',
        locals: {
          message: message,
          icon: icon,
          mark_to_set: mark_to_set,
          options: options
        }
      )
    end

    def message_css_for_hide_state(box, message)
      if box.division == :trash
        'hide' unless message.is_trashed_for?(@box_user)
      else
        'hide' unless message.is_untrashed_for?(@box_user)
      end
    end

    def message_css_for_draft_state(message)
      'draft' if message.draft
    end

    def message_css_for_read_state(message)
      if message.is_unread_for?(@box_user)
        'unread panel-info'
      else
        'read'
      end
    end
  end
end

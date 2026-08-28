module MessageTrain
  # Conversations helper
  module ConversationsHelper
    def conversation_senders(conversation)
      names = []
      conversation.messages.each do |message|
        names << box_participant_name(message.sender)
      end
      names.uniq.to_sentence
    end

    def conversation_class(box, conversation)
      css_classes = []
      css_classes << conversation_css_for_read_state(conversation)
      css_classes << conversation_css_for_draft_state(conversation)
      css_classes << conversation_css_for_hide_state(box, conversation)
      css_classes.join(' ')
    end

    def conversation_trashed_toggle(conversation, collective = nil)
      render(
        partial: 'message_train/conversations/trashed_toggle',
        locals: { conversation: conversation, collective: collective }
      )
    end

    def conversation_read_toggle(conversation, collective = nil)
      render(
        partial: 'message_train/conversations/read_toggle',
        locals: { conversation: conversation, collective: collective }
      )
    end

    def conversation_ignored_toggle(conversation, collective = nil)
      render(
        partial: 'message_train/conversations/ignored_toggle',
        locals: { conversation: conversation, collective: collective }
      )
    end

    def conversation_deleted_toggle(conversation, collective = nil)
      render(
        partial: 'message_train/conversations/deleted_toggle',
        locals: { conversation: conversation, collective: collective }
      )
    end

    private

    def conversation_toggle(conv, icon, mark, method, title, options = {})
      kind = options.delete(:kind) || mark
      collective = options.delete(:collective)
      show_text = options.delete(:show_text)
      locals = {
        conversation: conv, icon: icon, title: title, show_text: show_text,
        mark_to_set: mark, kind: kind, collective: collective,
        options: conversation_toggle_options(mark, method, title, options, small: !show_text)
      }
      render(partial: 'message_train/conversations/toggle', locals: locals)
    end

    def conversation_toggle_options(mark, method, title, options = {}, small: true)
      options[:title] = title
      options[:class] = [
        'message-train-button',
        (small ? 'message-train-button--small' : nil),
        "#{mark}-toggle"
      ].compact.join(' ')
      options[:method] = method
      options
    end

    def conversation_css_for_hide_state(box, conversation)
      conversation_css_for_deleted_state(conversation) ||
        conversation_css_for_trash_state(box, conversation) ||
        conversation_css_for_ignore_state(box, conversation)
    end

    def conversation_css_for_deleted_state(conversation)
      'hide' unless conversation.includes_undeleted_for?(@box_user)
    end

    def conversation_css_for_trash_state(box, conversation)
      if box.division == :trash
        'hide' unless conversation.includes_trashed_for?(@box_user)
      elsif !conversation.includes_untrashed_for?(@box_user)
        'hide'
      end
    end

    def conversation_css_for_ignore_state(box, conversation)
      if box.division == :ignored
        'hide' unless conversation.participant_ignored?(@box_user)
      elsif conversation.participant_ignored?(@box_user)
        'hide'
      end
    end

    def conversation_css_for_draft_state(conversation)
      'draft' if conversation.includes_drafts_by?(@box_user)
    end

    def conversation_css_for_read_state(conversation)
      if conversation.includes_unread_for?(@box_user)
        'unread'
      else
        'read'
      end
    end
  end
end

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

    # rubocop:disable Metrics/ParameterLists
    def conversation_toggle(conv, icon, mark, method, title, options = {})
      options[:remote] = true
      options[:method] = method
      options[:title] = title
      options[:class] ||= ''
      options[:class] += " #{mark}-toggle"
      render(
        partial: 'message_train/conversations/toggle',
        locals: {
          conversation: conv,
          icon: icon,
          mark_to_set: mark,
          options: options
        }
      )
    end
    # rubocop:enable Metrics/ParameterLists

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # This really is this complex.
    def conversation_css_for_hide_state(box, conversation)
      return 'hide' unless conversation.includes_undeleted_for?(@box_user)
      return 'hide' if box.division == :trash &&
                       !conversation.includes_trashed_for?(@box_user)
      return 'hide' if box.division != :trash &&
                       !conversation.includes_untrashed_for?(@box_user)

      if box.division == :ignored
        'hide' unless conversation.participant_ignored?(@box_user)
      elsif conversation.participant_ignored?(@box_user)
        'hide'
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity

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

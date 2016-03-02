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

      css_classes << if conversation.includes_unread_for?(@box_user)
                       'unread'
                     else
                       'read'
                     end

      conversation.includes_drafts_by?(@box_user) && css_classes << 'draft'

      !conversation.includes_undeleted_for?(@box_user) && css_classes << 'hide'

      if box.division == :trash
        !conversation.includes_trashed_for?(@box_user) &&
          css_classes << 'hide'
      else
        !conversation.includes_untrashed_for?(@box_user) &&
          css_classes << 'hide'
        if box.division == :ignored
          !conversation.participant_ignored?(@box_user) && css_classes << 'hide'
        else
          conversation.participant_ignored?(@box_user) && css_classes << 'hide'
        end
      end
      css_classes.uniq.join(' ')
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
  end
end

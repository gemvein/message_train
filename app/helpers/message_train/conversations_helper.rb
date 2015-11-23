module MessageTrain
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

      if conversation.includes_unread_for?(@box_user)
        css_classes << 'unread'
      else
        css_classes << 'read'
      end

      if conversation.includes_drafts_by?(@box_user)
        css_classes << 'draft'
      end

      unless conversation.includes_undeleted_for?(@box_user)
        css_classes << 'hide'
      end

      if box.division == :trash
        unless conversation.includes_trashed_for?(@box_user)
          css_classes << 'hide'
        end
      else
        unless conversation.includes_untrashed_for?(@box_user)
          css_classes << 'hide'
        end
        if box.division == :ignored
          unless conversation.is_ignored?(@box_user)
            css_classes << 'hide'
          end
        else
          if conversation.is_ignored?(@box_user)
            css_classes << 'hide'
          end
        end
      end
      css_classes.uniq.join(' ')
    end

    def conversation_trashed_toggle(conversation, collective = nil)
      render partial: 'message_train/conversations/trashed_toggle', locals: { conversation: conversation, collective: collective }
    end

    def conversation_read_toggle(conversation, collective = nil)
      render partial: 'message_train/conversations/read_toggle', locals: { conversation: conversation, collective: collective }
    end

    def conversation_ignored_toggle(conversation, collective = nil)
      render partial: 'message_train/conversations/ignored_toggle', locals: { conversation: conversation, collective: collective }
    end

    def conversation_deleted_toggle(conversation, collective = nil)
      render partial: 'message_train/conversations/deleted_toggle', locals: { conversation: conversation, collective: collective }
    end

  private

    def conversation_toggle(conversation, icon, mark_to_set, method, title, options = {})
      options[:remote] = true
      options[:method] = method
      options[:title] = title
      options[:class] ||= ""
      options[:class] += " " + mark_to_set.to_s + "-toggle"
      render partial: 'message_train/conversations/toggle', locals: {
                                                            conversation: conversation,
                                                            icon: icon,
                                                            mark_to_set: mark_to_set,
                                                            options: options
                                                        }
    end
  end
end

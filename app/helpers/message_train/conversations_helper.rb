module MessageTrain
  module ConversationsHelper
    def conversation_senders(conversation)
      conversation.messages.collect { |x| box_participant_name(x.sender) }.uniq.to_sentence
    end

    def conversation_class(box, conversation)
      css_classes = []

      if conversation.includes_unread_for?(@box.parent)
        css_classes << 'unread'
      else
        css_classes << 'read'
      end

      if conversation.includes_drafts_by?(@box.parent)
        css_classes << 'draft'
      end

      unless conversation.includes_undeleted_for?(box.parent)
        css_classes << 'hide'
      end

      if box.division == :trash
        unless conversation.includes_trashed_for?(box.parent)
          css_classes << 'hide'
        end
      else
        unless conversation.includes_untrashed_for?(box.parent)
          css_classes << 'hide'
        end
        if box.division == :ignored
          unless conversation.is_ignored?(box.parent)
            css_classes << 'hide'
          end
        else
          if conversation.is_ignored?(box.parent)
            css_classes << 'hide'
          end
        end
      end
      css_classes.uniq.join(' ')
    end

    def conversation_trashed_toggle(conversation)
      render partial: 'message_train/conversations/trashed_toggle', locals: { conversation: conversation }
    end

    def conversation_read_toggle(conversation)
      render partial: 'message_train/conversations/read_toggle', locals: { conversation: conversation }
    end

    def conversation_ignored_toggle(conversation)
      render partial: 'message_train/conversations/ignored_toggle', locals: { conversation: conversation }
    end

    def conversation_deleted_toggle(conversation)
      render partial: 'message_train/conversations/deleted_toggle', locals: { conversation: conversation }
    end

    def conversation_toggle(conversation, icon, mark_to_set, method, title, options = {})
      options[:remote] = true
      options[:method] = method
      options[:title] = title
      render partial: 'message_train/conversations/toggle', locals: {
                                                            conversation: conversation,
                                                            icon: icon,
                                                            mark_to_set: mark_to_set,
                                                            options: options
                                                        }
    end
  end
end

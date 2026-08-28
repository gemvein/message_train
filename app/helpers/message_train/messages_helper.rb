module MessageTrain
  # Messages helper
  module MessagesHelper
    MARKDOWN_RENDERER = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(safe_links_only: true),
      autolink: true, tables: true, fenced_code_blocks: true,
      no_intra_emphasis: true, strikethrough: true
    ).freeze

    def message_body(message)
      sanitize(MARKDOWN_RENDERER.render(message.body.to_s))
    end

    def message_class(box, message)
      css_classes = []
      css_classes << message_css_for_read_state(message)
      css_classes << message_css_for_draft_state(message)
      css_classes << message_css_for_hide_state(box, message)
      css_classes.join(' ')
    end

    def message_trashed_toggle(message, collective = nil)
      render(
        partial: 'message_train/messages/trashed_toggle',
        locals: { message: message, collective: collective }
      )
    end

    def message_read_toggle(message, collective = nil)
      render(
        partial: 'message_train/messages/read_toggle',
        locals: { message: message, collective: collective }
      )
    end

    def message_deleted_toggle(message, collective = nil)
      render(
        partial: 'message_train/messages/deleted_toggle',
        locals: { message: message, collective: collective }
      )
    end

    def message_recipients(message)
      message.recipients.collect { |x| box_participant_name(x) }.to_sentence
    end

    private

    def message_toggle(message, icon, mark_to_set, title, collective, options = {})
      kind = options.delete(:kind) || mark_to_set
      render(
        partial: 'message_train/messages/toggle',
        locals: {
          message: message,
          icon: icon,
          title: title,
          mark_to_set: mark_to_set,
          kind: kind,
          collective: collective,
          options: message_toggle_options(message, mark_to_set, title, options)
        }
      )
    end

    def message_toggle_options(message, mark_to_set, title, options = {})
      options[:id] = "mark_#{mark_to_set}_#{message.id}"
      options[:class] = 'mark-link'
      options[:title] = title
      options[:method] = :put
      options
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

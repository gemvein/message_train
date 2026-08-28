module MessageTrain
  # Application helper
  module ApplicationHelper
    ICON_LABELS = {
      'plus' => '+',
      'trash' => '🗑',
      'inbox' => '📥',
      'eye-open' => '👁',
      'eye-close' => '🚫',
      'remove' => '✕',
      'volume-up' => '🔔',
      'volume-off' => '🔕',
      'paperclip' => '📎',
      'refresh spinning' => '⟳',
      'check' => '✓'
    }.freeze

    def message_train_widget
      render partial: 'message_train/application/widget'
    end

    FLASH_ALERT_CLASSES = { notice: 'info', alert: 'warning', error: 'danger' }.freeze

    def flash_alert_class(flash_type)
      FLASH_ALERT_CLASSES.fetch(flash_type.to_sym, flash_type.to_s)
    end

    def fuzzy_date(date)
      time = Time.parse(date.strftime('%F %T'))
      change_in_time = Time.now - time
      return :just_now.l if (0..1.minute).cover? change_in_time
      l(time, format: fuzzy_date_format(change_in_time))
    end

    # Replacements for the bootstrap_leather helpers the views used to
    # depend on, backed by plain semantic HTML instead of Bootstrap markup.

    def add_title(text)
      content_for(:title) { text }
    end

    def add_subtitle(text)
      content_for(:subtitle) { text }
    end

    def icon(name, extra_class: nil)
      content_tag(
        :span, ICON_LABELS.fetch(name, ''),
        class: ['message-train-icon', extra_class].compact.join(' '),
        aria: { hidden: 'true' }
      )
    end

    def badge(text, extra_class = nil)
      content_tag(
        :span, text, class: ['message-train-badge', extra_class].compact.join(' ')
      )
    end

    def nav_item(text, link, options = {})
      content_tag(:li, link_to(text, link, options))
    end

    def dropdown_nav_item(text, _url, &block)
      content_tag(:details, class: 'message-train-dropdown-nav-item') do
        content_tag(:summary, text) + content_tag(:ul, capture(&block), class: 'dropdown-menu')
      end
    end

    def icon_button_to(extra_class, icon_name, text, url, options = {})
      button_to(
        icon(icon_name) + text, url,
        options.merge(class: [options[:class], extra_class].compact.join(' '))
      )
    end

    def modal(id, title, &block)
      content_tag(:dialog, id: id) do
        content_tag(:h2, title) + capture(&block)
      end
    end

    private

    def fuzzy_date_format(change_in_time)
      case change_in_time
      when 1.minute..1.day
        :fuzzy_today
      when 1.day..1.week
        :fuzzy_this_week
      when 1.week..1.year
        :fuzzy_date_without_year
      else
        :fuzzy_date
      end
    end
  end
end

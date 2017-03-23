module MessageTrain
  # Application helper
  module ApplicationHelper
    def message_train_widget
      render partial: 'message_train/application/widget'
    end

    def fuzzy_date(date)
      time = Time.parse(date.strftime('%F %T'))
      change_in_time = Time.now - time
      return :just_now.l if (0..1.minute).cover? change_in_time
      l(time, format: fuzzy_date_format(change_in_time))
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

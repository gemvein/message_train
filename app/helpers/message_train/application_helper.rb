module MessageTrain
  # Application helper
  module ApplicationHelper
    def message_train_widget
      render partial: 'message_train/application/widget'
    end

    def fuzzy_date(date)
      time = Time.parse(date.strftime('%F %T'))
      case Time.now - time
      when 0..1.minute
        :just_now.l
      when 1.minute..1.day
        l(time, format: :fuzzy_today)
      when 1.day..1.week
        l(time, format: :fuzzy_this_week)
      when 1.week..1.year
        l(time, format: :fuzzy_date_without_year)
      else
        l(time, format: :fuzzy_date)
      end
    end
  end
end

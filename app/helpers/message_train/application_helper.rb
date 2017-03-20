module MessageTrain
  # Application helper
  module ApplicationHelper
    def message_train_widget
      render partial: 'message_train/application/widget'
    end

    def fuzzy_date(date)
      time = Time.parse(date.strftime('%F %T'))
      dtime = Time.now - time
      return :just_now.l if (0..1.minute).cover? dtime
      format = case dtime
               when 1.minute..1.day
                 :fuzzy_today
               when 1.day..1.week
                 :fuzzy_this_week
               when 1.week..1.year
                 :fuzzy_date_without_year
               else
                 :fuzzy_date
               end
      l(time, format: format)
    end
  end
end

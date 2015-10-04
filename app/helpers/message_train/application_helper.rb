module MessageTrain
  module ApplicationHelper

    def message_train_widget
      render partial: 'message_train/application/widget'
    end

    def fuzzy_date(date)
      time = Time.parse(date.strftime('%F %T'))
      # Don't get confused: ">" here means "after", not "more than"
      if time > 1.minute.ago
        :just_now.l
      elsif time > 1.day.ago
        l(time, format: :fuzzy_today)
      elsif time > 1.week.ago
        l(time, format: :fuzzy_this_week)
      elsif time > 1.year.ago
        l(time, format: :fuzzy_date_without_year)
      else
        l(time, format: :fuzzy_date)
      end

    end

  end
end

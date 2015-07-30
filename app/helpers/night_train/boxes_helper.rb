module NightTrain
  module BoxesHelper
    def box_nav_item(box_division)
      box = NightTrain::Box.new(send(NightTrain.configuration.current_user_method), box_division)
      text = box.title
      link = night_train.box_path(box_division)
      if box.unread_count > 0
        text << ' '
        text << badge(box.unread_count.to_s, 'info pull-right')
      end
      nav_item text, link
    end
  end
end

module MessageTrain
  module BoxesHelper

    def box_nav_item(box)
      text = box.title
      link = message_train.box_path(box.division)
      unread_count = box.unread_count
      if unread_count > 0
        text << badge(unread_count.to_s.gsub(/\s+/, ""), 'info pull-right')
      end
      nav_item text.gsub(/[\n\t]/,'').html_safe, link
    end

    def box_list_item(box, html_options = {})
      render partial: 'message_train/boxes/list_item', locals: { box: box, html_options: html_options, unread_count: box.unread_count }
    end

    def boxes_widget(box_user)
      render partial: 'message_train/boxes/widget', locals: { boxes: box_user.all_boxes }
    end

    def boxes_dropdown_list(box_user, options = {})
      render partial: 'message_train/boxes/dropdown_list', locals: { boxes: box_user.all_boxes }
    end

    def box_participant_name(participant)
      participant.send(MessageTrain.configuration.name_columns[participant.class.table_name.to_sym])
    end

    def box_participant_slug(participant)
      participant.send(MessageTrain.configuration.slug_columns[participant.class.table_name.to_sym])
    end

  end
end

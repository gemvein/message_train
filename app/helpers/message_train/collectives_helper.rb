module MessageTrain
  module CollectivesHelper

    def collective_boxes_widget(collective, box_user)
      render partial: 'message_train/collectives/widget', locals: { collective: collective, box_user: box_user }
    end

    def collective_nav_item(box)
      text = collective_name(box.parent)
      link = message_train.collective_box_path(collective_path_part(box.parent), :in)
      unread_count = box.unread_count
      if unread_count > 0
        text << badge(unread_count.to_s, 'info pull-right')
      end
      nav_item text.html_safe, link
    end

    def collective_list_item(box, html_options = {})
      render partial: 'message_train/collectives/list_item', locals: { box: box, html_options: html_options, unread_count: box.unread_count }
    end

    def collective_boxes_dropdown_list(box_user)
      total_unread_count = box_user.collective_boxes.collect { |table_sym, collectives| collectives.collect { |collective_box| collective_box.unread_count } }.flatten.sum
      render partial: 'message_train/collectives/dropdown_list', locals: { collective_boxes: box_user.collective_boxes, total_unread_count: total_unread_count }
    end

    def collective_name(collective)
      collective.send(MessageTrain.configuration.name_columns[collective.class.table_name.to_sym])
    end

    def collective_slug(collective)
      collective.send(MessageTrain.configuration.slug_columns[collective.class.table_name.to_sym])
    end

    def collective_path_part(collective)
      "#{collective.class.table_name}:#{collective_slug(collective)}"
    end

  end
end
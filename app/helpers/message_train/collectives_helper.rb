module MessageTrain
  # Collectives helper
  module CollectivesHelper
    def collective_boxes_widget(collective, box_user)
      render(
        partial: 'message_train/collectives/widget',
        locals: { collective: collective, box_user: box_user }
      )
    end

    def collective_nav_item(box, box_user)
      text = collective_name(box.parent)
      if box.parent.allows_receiving_by? box_user
        division = :in
      elsif box.parent.allows_sending_by? box_user
        division = :sent
      else
        return
      end
      link = message_train.collective_box_path(box.parent.path_part, division)
      unread_count = box.unread_count
      unread_count > 0 && text << badge(unread_count.to_s, 'info pull-right')
      nav_item text.html_safe, link
    end

    def collective_list_item(box, html_options = {})
      render(
        partial: 'message_train/collectives/list_item',
        locals: {
          box: box,
          html_options: html_options,
          unread_count: box.unread_count
        }
      )
    end

    def collective_boxes_dropdown_list(box_user)
      total_unread_count = {}
      show = {}
      box_user.collective_boxes.each do |table_sym, collectives|
        total_unread_count[table_sym] = collectives.collect(&:unread_count).sum
        show[table_sym] = collectives.select do |collective_box|
          collective_box.parent.allows_sending_by?(box_user) ||
            collective_box.parent.allows_receiving_by?(box_user)
        end.any?
      end
      render(
        partial: 'message_train/collectives/dropdown_list',
        locals: {
          collective_boxes: box_user.collective_boxes,
          total_unread_count: total_unread_count,
          show: show,
          box_user: box_user
        }
      )
    end

    def collective_name(collective)
      collective.send(
        MessageTrain.configuration.name_columns[
          collective.class.table_name.to_sym
        ]
      )
    end

    def collective_slug(collective)
      collective.send(
        MessageTrain.configuration.slug_columns[
          collective.class.table_name.to_sym
        ]
      )
    end
  end
end

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
      parent = box.parent
      return unless parent.allows_access_by? box_user
      text = collective_name(parent)
      count = box.unread_count
      text << badge(count.to_s, 'info pull-right') if count > 0
      nav_item(
        text.html_safe,
        message_train.collective_box_path(
          parent.path_part,
          default_division_for_box(box, box_user)
        )
      )
    end

    def default_division_for_box(box, box_user)
      if box.parent.allows_receiving_by? box_user
        :in
      elsif box.parent.allows_sending_by? box_user
        :sent
      end
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

    def collectives_cache_key(collective_boxes, box_user)
      parts = [
        'collectives-dropdown',
        box_user
      ]
      collective_boxes.collect do |table_name, x|
        updated_at = x.collect do |y|
          y.conversations && y.conversations.maximum(:updated_at)
        end.compact.max
        updated_at && parts << [
          table_name,
          updated_at
        ]
      end
      parts
    end
  end
end

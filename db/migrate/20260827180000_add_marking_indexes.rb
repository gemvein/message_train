class AddMarkingIndexes < ActiveRecord::Migration[7.1]
  def change
    add_index :message_train_receipts, :marked_read
    add_index :message_train_receipts, :marked_trash
    add_index :message_train_receipts, :marked_deleted
    add_index :message_train_conversations, :updated_at
    add_index :message_train_messages, :draft
  end
end

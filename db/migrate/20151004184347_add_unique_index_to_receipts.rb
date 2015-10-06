class AddUniqueIndexToReceipts < ActiveRecord::Migration
  def change
    add_index :message_train_receipts, [:message_id, :recipient_type, :recipient_id], name: :message_recipient, unique: true
  end
end

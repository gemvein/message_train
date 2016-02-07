# This migration comes from message_train (originally 20150901183458)
class AddReceivedThroughToMessageTrainReceipts < ActiveRecord::Migration
  def change
    add_reference :message_train_receipts, :received_through, polymorphic: true
    add_index :message_train_receipts, [:received_through_type, :received_through_id], name: :index_message_train_receipts_on_received_through
  end
end

class CreateMessageTrainReceipts < ActiveRecord::Migration
  def change
    create_table :message_train_receipts do |t|
      t.references :recipient, polymorphic: true
      t.references :message_train_message, index: true, foreign_key: true
      t.boolean :marked_read, default: false
      t.boolean :marked_trash, default: false
      t.boolean :marked_deleted, default: false
      t.boolean :sender, default: false

      t.timestamps null: false
    end

    add_index :message_train_receipts, [:recipient_type, :recipient_id], name: :index_message_train_receipts_on_recipient
  end
end

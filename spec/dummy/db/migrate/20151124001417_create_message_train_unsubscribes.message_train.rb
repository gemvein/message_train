# This migration comes from message_train (originally 20151124000820)
class CreateMessageTrainUnsubscribes < ActiveRecord::Migration
  def change
    create_table :message_train_unsubscribes do |t|
      t.references :recipient, polymorphic: true
      t.references :from, polymorphic: true

      t.timestamps null: false
    end

    add_index :message_train_unsubscribes, [:recipient_type, :recipient_id], name: :unsubscribe_recipient
    add_index :message_train_unsubscribes, [:from_type, :from_id], name: :unsubscribe_from
    add_index :message_train_unsubscribes, [:recipient_type, :recipient_id, :from_type, :from_id], name: :unsubscribes, unique: true
  end
end

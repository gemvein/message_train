# This migration comes from message_train (originally 20150721145319)
class CreateMessageTrainConversations < ActiveRecord::Migration
  def change
    create_table :message_train_conversations do |t|
      t.string :subject

      t.timestamps null: false
    end
  end
end

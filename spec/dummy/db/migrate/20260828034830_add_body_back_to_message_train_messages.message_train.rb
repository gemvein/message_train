# This migration comes from message_train (originally 20260827200000)
class AddBodyBackToMessageTrainMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :message_train_messages, :body, :text
  end
end

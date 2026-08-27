# This migration comes from message_train (originally 20260827171549)
class RemoveBodyFromMessageTrainMessages < ActiveRecord::Migration[7.1]
  def change
    remove_column :message_train_messages, :body, :text
  end
end

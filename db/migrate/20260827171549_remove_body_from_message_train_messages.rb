class RemoveBodyFromMessageTrainMessages < ActiveRecord::Migration[7.1]
  def change
    remove_column :message_train_messages, :body, :text
  end
end

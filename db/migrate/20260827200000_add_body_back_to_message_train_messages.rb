class AddBodyBackToMessageTrainMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :message_train_messages, :body, :text
  end
end

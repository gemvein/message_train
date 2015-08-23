class CreateMessageTrainConversations < ActiveRecord::Migration
  def change
    create_table :message_train_conversations do |t|
      t.string :subject

      t.timestamps null: false
    end
  end
end

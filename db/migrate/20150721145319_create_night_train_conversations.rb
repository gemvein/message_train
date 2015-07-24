class CreateNightTrainConversations < ActiveRecord::Migration
  def change
    create_table :night_train_conversations do |t|
      t.string :subject

      t.timestamps null: false
    end
  end
end

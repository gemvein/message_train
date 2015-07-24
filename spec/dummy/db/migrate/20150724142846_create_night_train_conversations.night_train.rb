# This migration comes from night_train (originally 20150721145319)
class CreateNightTrainConversations < ActiveRecord::Migration
  def change
    create_table :night_train_conversations do |t|
      t.string :subject

      t.timestamps null: false
    end
  end
end

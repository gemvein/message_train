# This migration comes from message_train (originally 20150721161144)
class CreateMessageTrainAttachments < ActiveRecord::Migration
  def change
    create_table :message_train_attachments do |t|
      t.references :message_train_message, index: true, foreign_key: true
      t.attachment :attachment

      t.timestamps null: false
    end
  end
end

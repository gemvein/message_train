# This migration comes from message_train (originally 20150721161144)
class CreateMessageTrainAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :message_train_attachments do |t|
      t.references :message_train_message, index: true, foreign_key: true
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at

      t.timestamps null: false
    end
  end
end

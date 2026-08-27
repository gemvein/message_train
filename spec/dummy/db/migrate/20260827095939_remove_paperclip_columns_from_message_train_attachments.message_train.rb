# This migration comes from message_train (originally 20260827095938)
class RemovePaperclipColumnsFromMessageTrainAttachments < ActiveRecord::Migration[7.1]
  def change
    remove_column :message_train_attachments, :attachment_file_name, :string
    remove_column :message_train_attachments, :attachment_content_type, :string
    remove_column :message_train_attachments, :attachment_file_size, :integer
    remove_column :message_train_attachments, :attachment_updated_at, :datetime
  end
end

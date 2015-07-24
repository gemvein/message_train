class CreateNightTrainAttachments < ActiveRecord::Migration
  def change
    create_table :night_train_attachments do |t|
      t.references :message, index: true, foreign_key: true
      t.attachment :attachment

      t.timestamps null: false
    end
  end
end

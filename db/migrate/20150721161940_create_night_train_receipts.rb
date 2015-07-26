class CreateNightTrainReceipts < ActiveRecord::Migration
  def change
    create_table :night_train_receipts do |t|
      t.references :recipient, polymorphic: true, index: true
      t.references :message, index: true, foreign_key: true
      t.boolean :marked_read, default: false
      t.boolean :marked_trash, default: false
      t.boolean :marked_deleted, default: false
      t.boolean :sender, default: false

      t.timestamps null: false
    end
  end
end

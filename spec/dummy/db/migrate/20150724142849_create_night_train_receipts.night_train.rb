# This migration comes from night_train (originally 20150721161940)
class CreateNightTrainReceipts < ActiveRecord::Migration
  def change
    create_table :night_train_receipts do |t|
      t.references :recipient, polymorphic: true, index: true
      t.references :message, index: true, foreign_key: true
      t.boolean :marked_read
      t.boolean :marked_trash
      t.boolean :marked_deleted
      t.string :division, index: true

      t.timestamps null: false
    end
  end
end

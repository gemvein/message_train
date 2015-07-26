# This migration comes from night_train (originally 20150721160322)
class CreateNightTrainMessages < ActiveRecord::Migration
  def change
    create_table :night_train_messages do |t|
      t.references :conversation, index: true, foreign_key: true
      t.references :sender, polymorphic: true, index: true
      t.text :recipients_to_save
      t.string :subject
      t.text :body
      t.boolean :draft

      t.timestamps null: false
    end
  end
end

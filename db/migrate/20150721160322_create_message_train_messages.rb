class CreateMessageTrainMessages < ActiveRecord::Migration
  def change
    create_table :message_train_messages do |t|
      t.references :conversation, index: true, foreign_key: true
      t.references :sender, polymorphic: true, index: true
      t.text :recipients_to_save
      t.string :subject
      t.text :body
      t.boolean :draft, default: false

      t.timestamps null: false
    end
  end
end

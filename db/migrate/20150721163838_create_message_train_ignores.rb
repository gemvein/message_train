class CreateMessageTrainIgnores < ActiveRecord::Migration
  def change
    create_table :message_train_ignores do |t|
      t.references :participant, polymorphic: true
      t.references :conversation, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :message_train_ignores, [:participant_type, :participant_id], name: 'participant_index'
  end
end
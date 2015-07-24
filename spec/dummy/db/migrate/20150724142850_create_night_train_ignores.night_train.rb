# This migration comes from night_train (originally 20150721163838)
class CreateNightTrainIgnores < ActiveRecord::Migration
  def change
    create_table :night_train_ignores do |t|
      t.references :recipient, polymorphic: true, index: true
      t.references :conversation, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

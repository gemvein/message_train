class CreateGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :groups do |t|
      t.string :title
      t.string :slug, unique: true
      t.text :description

      t.timestamps null: false
    end
  end
end

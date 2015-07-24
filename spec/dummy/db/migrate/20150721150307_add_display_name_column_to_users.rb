class AddDisplayNameColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :display_name, :string
    add_column :users, :slug, :string, unique: true
  end
end

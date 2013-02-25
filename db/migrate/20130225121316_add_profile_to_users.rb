class AddProfileToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :body, :text
    add_column :users, :location, :string
    add_column :users, :achievements, :text, default: {registered: true}.to_yaml
    add_column :users, :personal_url, :string

    add_index :users, :name
    add_index :users, :location
  end
end

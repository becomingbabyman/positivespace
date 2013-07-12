class AddMagnetismToUsers < ActiveRecord::Migration
  def change
    add_column :users, :magnetism, :integer, default: 0
    add_index :users, :magnetism
  end
end

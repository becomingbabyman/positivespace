class AddHideToUsers < ActiveRecord::Migration
  def change
    add_column :users, :account_visible, :boolean, default: true
    add_index :users, :account_visible
    add_column :users, :account_active, :boolean, default: true
    add_index :users, :account_active
  end
end

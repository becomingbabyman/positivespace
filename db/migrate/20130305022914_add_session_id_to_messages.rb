class AddSessionIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :session_id, :integer
    add_index :messages, :session_id
  end
end

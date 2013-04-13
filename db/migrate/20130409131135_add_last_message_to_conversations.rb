class AddLastMessageToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :last_message_id, :string
    add_index :conversations, :last_message_id
    add_column :conversations, :last_message_body, :text
    add_column :conversations, :prompt, :text
    add_index :conversations, :prompt
  end
end

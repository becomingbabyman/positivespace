class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.integer :from_id
      t.integer :to_id
      t.string :state

      t.timestamps
    end
    add_index :conversations, :from_id
    add_index :conversations, :to_id
    add_index :conversations, :state
  end
end

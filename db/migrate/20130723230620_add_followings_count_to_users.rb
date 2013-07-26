class AddFollowingsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :follows_count, :integer, default: 0, null: false
    add_column :users, :sent_conversations_count, :integer, default: 0, null: false
    add_column :users, :recieved_conversations_count, :integer, default: 0, null: false
    add_column :users, :sent_messages_count, :integer, default: 0, null: false
    add_column :users, :recieved_messages_count, :integer, default: 0, null: false
    add_column :conversations, :messages_count, :integer, default: 0, null: false

    add_index :users, :follows_count
    add_index :users, :sent_conversations_count
    add_index :users, :recieved_conversations_count
    add_index :users, :sent_messages_count
    add_index :users, :recieved_messages_count
    add_index :conversations, :messages_count

    User.reset_column_information
    Conversation.reset_column_information
    Message.reset_column_information

    say_with_time "Set user counts" do
      User.find_in_batches do |group|
        sleep(5) # Make sure it doesn't get too crowded in there!
        group.each do |u|
          u.update_attribute :follows_count, u.follows.count
          User.reset_counters(u.id, :sent_conversations, :recieved_conversations, :sent_messages, :recieved_messages)
        end
      end
    end

    say_with_time "Set conversation counts" do
      Conversation.find_in_batches do |group|
        sleep(5) # Make sure it doesn't get too crowded in there!
        group.each do |c|
          Conversation.reset_counters(c.id, :messages)
        end
      end
    end

  end
end

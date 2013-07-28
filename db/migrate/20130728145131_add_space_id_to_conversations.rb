class AddSpaceIdToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :space_id, :integer
    add_column :spaces, :conversations_count, :integer, default: 0, null: false
    add_column :users, :spaces_count, :integer, default: 0, null: false

    add_index :conversations, :space_id
    add_index :spaces, :conversations_count
    add_index :users, :spaces_count

    User.reset_column_information
    Space.reset_column_information
    Conversation.reset_column_information

    say_with_time "Set conversation space" do
      Conversation.find_in_batches do |group|
        sleep(10) # Make sure it doesn't get too crowded in there!
        group.each do |c|
          space = c.to.spaces.where(prompt: c.prompt).first
          c.update_attribute :space, space if space
          Space.reset_counters(space.id, :conversations) if space
        end
      end
    end

    say_with_time "Set user spaces_count" do
      User.find_in_batches do |group|
        sleep(10) # Make sure it doesn't get too crowded in there!
        group.each do |u|
          User.reset_counters(u.id, :spaces)
        end
      end
    end

  end
end

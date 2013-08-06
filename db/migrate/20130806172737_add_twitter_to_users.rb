class AddTwitterToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twitter_id, :integer
    add_index :users, :twitter_id
    add_column :users, :twitter_handle, :string
    add_index :users, :twitter_handle
    add_column :users, :twitter_time_zone, :string
    add_column :users, :twitter_statuses_count, :integer
    add_index :users, :twitter_statuses_count
    add_column :users, :twitter_listed_count, :integer
    add_index :users, :twitter_listed_count
    add_column :users, :twitter_friends_count, :integer
    add_index :users, :twitter_friends_count
    add_column :users, :twitter_followers_count, :integer
    add_index :users, :twitter_followers_count
    add_column :users, :twitter_verified, :boolean
    add_index :users, :twitter_verified
    add_column :users, :show_facebook, :boolean, default: true, null: false
    add_column :users, :show_twitter, :boolean, default: true, null: false
  end
end

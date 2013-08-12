class AddLinkedinToUsers < ActiveRecord::Migration
  def change
    add_column :users, :linkedin_id, :string
    add_index :users, :linkedin_id
    add_column :users, :linkedin_credentials, :text
    add_column :users, :linkedin_profile_url, :text
    add_column :users, :linkedin_connections_count, :integer
    add_column :users, :show_linkedin, :boolean, default: true, null: false
  end
end

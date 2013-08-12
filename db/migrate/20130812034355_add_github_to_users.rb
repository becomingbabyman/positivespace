class AddGithubToUsers < ActiveRecord::Migration
  def change
    add_column :users, :github_id, :integer
    add_index :users, :github_id
    add_column :users, :show_github, :boolean, default: true, null: false

    add_column :users, :github_credentials, :text
    add_column :users, :github_hireable, :boolean
    add_column :users, :github_login, :string
    add_column :users, :github_type, :string
    add_column :users, :github_company, :string
    add_column :users, :github_public_repos, :integer
    add_column :users, :github_public_gists, :integer
    add_column :users, :github_followers, :integer
    add_column :users, :github_following, :integer
    add_column :users, :github_created_at, :datetime

    add_column :users, :github_email, :string
    add_index :users, :github_email
    add_column :users, :linkedin_email, :string
    add_index :users, :linkedin_email
    add_column :users, :facebook_email, :string
    add_index :users, :facebook_email
  end
end

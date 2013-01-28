class AddToUsers < ActiveRecord::Migration
  def change
    add_column :users, :permissions,	:integer, :default => 0
    add_column :users, :facebook_id,	:string
    add_column :users, :username,   	:string
    add_column :users, :slug,       	:string
    add_column :users, :acq_source,     :string
    add_column :users, :acq_medium,     :string

    add_index "users", ["permissions"], :name => "index_users_on_permissions"
    add_index "users", ["facebook_id"], :name => "index_users_on_facebook_id"
    add_index "users", ["username"],	:unique => true
    add_index "users", ["slug"],        :unique => true
  end
end
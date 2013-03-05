class AddAutorespondersToUsers < ActiveRecord::Migration
  def change
    add_column :users, :positive_response, :text
    add_column :users, :negative_response, :text
  end
end

class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :user_id
      t.string :code
      t.integer :max_use_count, default: 1
      t.integer :current_use_count, default: 0
      t.integer :share_count, default: 0
      t.integer :impressions_count, default: 0

      t.timestamps
    end
    add_index :invitations, :user_id
    add_index :invitations, :code

    add_column :users, :invitation_id, :integer
    add_column :users, :invitation_count, :integer, default: 0
    add_index :users, :invitation_count
    add_column :users, :state, :string
    add_index :users, :state
  end
end

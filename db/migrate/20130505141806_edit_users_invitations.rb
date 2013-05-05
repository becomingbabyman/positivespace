class EditUsersInvitations < ActiveRecord::Migration
	def change
		remove_column :users, :invitation_count
		add_column :users, :remaining_invitations_count, :integer, default: 0
		add_index :users, :remaining_invitations_count
	end
end

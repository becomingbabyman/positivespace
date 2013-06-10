class AddSettingsToUsers < ActiveRecord::Migration
	def change
		add_column :users, :settings, :text, default: {}

		User.reset_column_information

		say_with_time "Add basic email toggles to users" do
			User.all.each do |user|
				user.settings[:notifications] = {}
				user.settings[:notifications][:email] = {}
				user.settings[:notifications][:email][:every_new_message] = true
				user.settings[:notifications][:email][:daily_new_messages_digest] = false
				user.settings[:notifications][:email][:weekly_new_messages_digest] = true
				user.settings[:notifications][:email][:daily_pending_messages_reminder] = true
				user.settings[:notifications][:email][:weekly_pending_messages_reminder] = false
				user.settings[:notifications][:email][:new_followers] = true
				user.settings[:notifications][:email][:spaces_you_might_like] = true
				user.settings[:notifications][:email][:new_spaces] = true
				user.settings[:notifications][:email][:popular_spaces] = true
				user.save
			end
		end
	end
end

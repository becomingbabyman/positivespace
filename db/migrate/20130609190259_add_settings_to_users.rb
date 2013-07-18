class AddSettingsToUsers < ActiveRecord::Migration
	def change
		add_column :users, :settings, :text, default: {}

		User.reset_column_information

		say_with_time "Add basic email toggles to users" do
			User.all.each do |user|
				user.initialize_settings
				user.save(:validate=>false)
			end
		end
	end
end

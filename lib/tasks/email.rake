namespace :email do
	desc "Send daily emails"
	task :daily => :environment do
		User.all.each do |user|
			NotificationsMailer.delay.daily_new_messages_digest(user.id) if user.settings.try(:[], :notifications).try(:[], :email).try(:[], :daily_new_messages_digest)
		end
	end

	desc "Send weekly emails"
	task :weekly => :environment do
		User.all.each do |user|
			NotificationsMailer.delay.weekly_new_messages_digest(user.id) if user.settings.try(:[], :notifications).try(:[], :email).try(:[], :weekly_new_messages_digest) and DateTime.now.strftime("%w") == 6 # only fire on Saturday
		end
	end
end

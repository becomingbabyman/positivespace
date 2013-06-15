namespace :email do
	desc "Send daily emails"
	task :daily => :environment do
		User.all.each do |user|
			NotificationsMailer.delay_for(1.hour).daily_new_messages_digest(user.id) if user.settings.try(:[], :notifications).try(:[], :email).try(:[], :daily_new_messages_digest)
			NotificationsMailer.delay.daily_pending_messages_reminder(user.id) if user.settings.try(:[], :notifications).try(:[], :email).try(:[], :daily_pending_messages_reminder)
		end
	end

	desc "Send weekly emails"
	task :weekly => :environment do
		User.all.each do |user|
			NotificationsMailer.delay.weekly_new_messages_digest(user.id) if user.settings.try(:[], :notifications).try(:[], :email).try(:[], :weekly_new_messages_digest) and DateTime.now.strftime("%w") == 6 # only fire on Saturday
			NotificationsMailer.delay_for(5.hours).weekly_pending_messages_reminder(user.id) if user.settings.try(:[], :notifications).try(:[], :email).try(:[], :weekly_pending_messages_reminder) and DateTime.now.strftime("%w") == 4 # only fire on Thursday
			NotificationsMailer.delay_for(3.hours).new_followers(user.id) if user.settings.try(:[], :notifications).try(:[], :email).try(:[], :new_followers) and DateTime.now.strftime("%w") == 5 # only fire on Friday
		end
	end
end

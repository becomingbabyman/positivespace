class DeviseCustomMailer < Devise::Mailer
	default :css => :email
	layout 'email'
end

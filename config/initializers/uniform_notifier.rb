if defined? UniformNotifier
	# javascript alert
	# UniformNotifier.alert = true

	# javascript console (Safari/Webkit browsers or Firefox w/Firebug installed)
	UniformNotifier.console = true

	# rails logger
	# UniformNotifier.rails_logger = true

	# airbrake
	# UniformNotifier.airbrake = true

	# customized logger
	# logger = File.open('notify.log', 'a+')
	# logger.sync = true
	# UniformNotifier.customized_logger = logger

	# growl without password
	UniformNotifier.growl = true
	# growl with passowrd
	UniformNotifier.growl = { :password => '' }

	# xmpp
	# UniformNotifier.xmpp = { :account => 'sender_account@jabber.org',
	#                          :password => 'password_for_jabber',
	#                          :receiver => 'recipient_account@jabber.org',
	#                          :show_online_status => true }
end

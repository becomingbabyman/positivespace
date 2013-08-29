if defined?(Sidekiq)
	Sidekiq.configure_server do |config|
		# TODO: increase when you have more redis memory to spare
		# Keep it low to keep the memory footprint low
		config.failures_max_count = 20
	end
end

if defined? Rack::MiniProfiler
	Rack::MiniProfiler.config.position = 'left'
	Rack::MiniProfiler.config.toggle_shortcut = 'Alt+p'
	Rack::MiniProfiler.config.start_hidden = false
end

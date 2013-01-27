require 'sidekiq/web'

Positivespace::Application.routes.draw do
	mount RailsAdmin::Engine => '/nameless', :as => 'rails_admin'
	devise_for :administrators
	# devise_scope :administrator do
	#	get '/nameless_wat' => 'devise/sessions#new'
	# end
	constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin? }
	constraints constraint do
		mount Sidekiq::Web, at: '/emptiness'
	end

	# root :to => "/nameless"
end

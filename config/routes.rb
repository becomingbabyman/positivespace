require 'sidekiq/web'

Positivespace::Application.routes.draw do

	mount RailsAdmin::Engine => '/nameless', :as => 'rails_admin'
	devise_for :administrators
	# devise_scope :administrator do
	#	get '/nameless_wat' => 'devise/sessions#new'
	# end
	constraint = lambda { |request| request.env['warden'].authenticate? and request.env['warden'].user.admin? }
	constraints constraint do
		mount Sidekiq::Web, at: '/emptiness'
	end
	devise_for :users, :controllers => { :omniauth_callbacks => 'users/omniauth_callbacks', :registrations => 'users/registrations', :sessions => 'users/sessions', :passwords => 'users/passwords' }
	devise_scope :user do
		# get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
		get '/login' => 'users/sessions#new'
		get '/logout' => 'devise/sessions#destroy'
		get '/register' => 'users/registrations#new'
		get '/settings' => 'users/registrations#edit'
		# get '/edit' => 'users#edit'
		get '/forgot' => 'users/passwords#new'
	end

	root :to => 'pages#home'
	
	resources :pages, path: '', only: :none do
		collection do
			get :me
			get :robots
			get :home
		end
	end

end

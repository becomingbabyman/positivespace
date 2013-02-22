require 'sidekiq/web'
require 'api_constraints'

Positivespace::Application.routes.draw do

	# TODO: add namespace
	# namespace :admin do
		# Administrations
		mount RailsAdmin::Engine => '/nameless', :as => 'rails_admin'
		devise_for :administrators
		constraint = lambda { |request| request.env['warden'].authenticate? and request.env['warden'].user.admin? }
		constraints constraint do
			mount Sidekiq::Web, at: '/emptiness'
		end
	# end


	# # TODO: figure out how to get this inside the versioned api namespace below
	# scope "/api", defaults: {format: 'json'} do
	# end

	namespace :api, defaults: {format: 'json'} do
		scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
			# Users
			devise_for :users, :module => "devise", :controllers => { :omniauth_callbacks => 'api/v1/users/omniauth_callbacks', :registrations => 'api/v1/users/registrations', :sessions => 'api/v1/users/sessions', :passwords => 'api/v1/users/passwords' }
			# devise_scope :user do
			#	# # get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
			#	# get '/login' => 'users/sessions#new'
			#	# get '/logout' => 'devise/sessions#destroy'
			#	# get '/register' => 'users/registrations#new'
			#	# get '/settings' => 'users/registrations#edit'
			#	# # get '/edit' => 'users#edit'
			#	# get '/forgot' => 'users/passwords#new'
			# end
			resources :users, only: [:index, :show]




			# Simplified user routes
			resources :users, path: '', only: [:show]
		end

		# scope module: :v2, constraints: ApiConstraints.new(version: 2, default: true) do
		# end
	end


	# Static pages
	resources :pages, path: '', only: :none do
		collection do
			get :robots
			get :home
		end
	end

	# Root
	root :to => 'pages#home'

	# Route wildcard routes to angular for client side routing
	match "*path", to: "pages#home"
end

require 'sidekiq/web'

Positivespace::Application.routes.draw do

	# Administrations
	mount RailsAdmin::Engine => '/nameless', :as => 'rails_admin'
	devise_for :administrators
	constraint = lambda { |request| request.env['warden'].authenticate? and request.env['warden'].user.admin? }
	constraints constraint do
		mount Sidekiq::Web, at: '/emptiness'
	end

	# Users
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
	resources :users, only: [:index, :show]


	# Static pages
	resources :pages, path: '', only: :none do
		collection do
			get :robots
			get :home
		end
	end

	# Root
	root :to => 'pages#home'

	# Simplified user routes
	resources :users, path: '', only: [:show]

	# Route wildcard routes to angular for client side routing
	match "*path", to: "pages#home"
end

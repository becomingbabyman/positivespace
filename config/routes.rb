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


	# TODO: figure out how to get this inside the versioned api namespace below
	scope "/api", defaults: {format: 'json'} do
		devise_for :users, :controllers => { :omniauth_callbacks => 'users/omniauth_callbacks', :registrations => 'users/registrations', :sessions => 'users/sessions', :passwords => 'users/passwords' }
		devise_scope :user do
			get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
			# get '/login' => 'users/sessions#new'
			# get '/logout' => 'devise/sessions#destroy'
			# get '/register' => 'users/registrations#new'
			# get '/settings' => 'users/registrations#edit'
			# # get '/edit' => 'users#edit'
			# get '/forgot' => 'users/passwords#new'
		end
	end

	namespace :api, defaults: {format: 'json'} do
		scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
			# Users
			resources :users, only: [:index, :show, :update] do
				resources :conversations, only: [:index, :show, :update]
				resources :messages, only: [:index, :show, :create, :update, :destroy]
			end

			# Images
			resources :images, only: [:create, :destroy, :show]

			# ## Simplified user routes
			# resources :users, path: '', only: [:show] do
			# end
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
	match "*path", to: "pages#wildcard"
	match '/robots.:format' => 'pages#robots'
	# match '/sitemap' => redirect('http://sitemap.positivespace.io')

	constraints subdomain: 's' do
		match '/:id' => "shortener/shortened_urls#show"
	end
end

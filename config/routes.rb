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
				collection do
					get :metrics
				end
				resources :conversations, only: [:index, :show, :update]
				resources :messages, only: [:index, :show, :create, :update, :destroy]
			end

			# Conversations
			resources :conversations, only: [:none] do
				resources :reviews, only: [:index, :create, :update]
			end

			# Images
			resources :images, only: [:create, :destroy, :show]

			# Tags
			resources :tags, only: [:index]

			# ## Simplified user routes
			# resources :users, path: '', only: [:show] do
			# end
		end

		# scope module: :v2, constraints: ApiConstraints.new(version: 2, default: true) do
		# end
	end


	# Mailgun email posting urls
	resources :emails, only: :none do
		collection do
			post :message
		end
	end


	# Static pages
	resources :pages, path: '', only: :none do
		collection do
			get :home
			get :robots
			get :iframe
		end
	end

	# Root
	root :to => 'pages#home'

	constraints subdomain: 's' do
		match '/:id' => "shortener/shortened_urls#show"
	end

	match '/embeds/:id' => "embeds#space" #TODO: REMOVE: after testing
	constraints subdomain: 'e' do
		match '/:id' => "embeds#space"
	end
	
	match '/sitemap' => redirect('http://static.positivespace.io/sitemaps/sitemap.xml.gz')
	match '/robots.:format' => 'pages#robots'
	
	# Route wildcard routes to angular for client side routing - only route URIs not URLs like .html or .jpg
	match "*path", to: "pages#wildcard", constraints: lambda { |request| !request.path.split('/').last.include?('.') }

end

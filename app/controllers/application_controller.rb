class ApplicationController < ActionController::Base
	protect_from_forgery

	before_filter :intercept_html_requests

	rescue_from CanCan::AccessDenied do |exception|
		if request.format == Mime::HTML
			redirect_to root_url, :alert => "You do not have permission to view that page."
		else
			render json: {errors: ["Sorry, you can't do that"]}, status: 401
		end
	end

	# Initialize cancan
	def current_ability
		@current_ability ||= Ability.new(current_user, params, positivespace_session_id, session)
	end

	def positivespace_session_id
		session[:positivespace_session_id] ||= SecureRandom.random_number(2_147_483_646)
	end

	# Helper method for picking allowed keys from a hash of params
	# http://www.quora.com/Backbone-js-1/How-well-does-backbone-js-work-with-rails
	def pick(hash, *keys)
		filtered = {}
		keys = keys.flatten.map{ |key| key.to_sym }
		hash.each do |key, value|
			filtered[key.to_sym] = value if keys.include?(key.to_sym)
		end
		filtered
	end

private

	def intercept_html_requests
		if request.format == Mime::HTML and (params[:controller] =~ /devise\/sessions|rails_admin\/main|users\/passwords/).nil?
			render('pages/home', layout: 'angular')
		end
	end

	# AngularJS automatically sends CSRF token as a header called X-XSRF
	# this makes sure rails gets it
	def verified_request?
		!protect_against_forgery? || request.get? ||
			form_authenticity_token == params[request_forgery_protection_token] || form_authenticity_token == request.headers['X-CSRF-Token'] ||
			request.headers['X-XSRF-Token'] && form_authenticity_token == request.headers['X-XSRF-Token'].gsub!(/\A"|"\Z/, '')
		end
end

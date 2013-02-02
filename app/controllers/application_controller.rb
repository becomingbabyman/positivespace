class ApplicationController < ActionController::Base
	protect_from_forgery

	# Default cancan redirect url
	rescue_from CanCan::AccessDenied do |exception|
		redirect_to root_url, :alert => "You do not have permission to view that page."
	end

	# Initialize cancan
	def current_ability
		@current_ability ||= Ability.new(current_user, params, positivespace_session_id, session)
	end

	def consignd_session_id
		@positivespace_session_id ||= SecureRandom.random_number(2_147_483_646)
	end


private

	# AngularJS automatically sends CSRF token as a header called X-XSRF
	# this makes sure rails gets it
	def verified_request?
		!protect_against_forgery? || request.get? ||
			form_authenticity_token == params[request_forgery_protection_token] ||
			form_authenticity_token == request.headers['X-XSRF-Token']
	end
end

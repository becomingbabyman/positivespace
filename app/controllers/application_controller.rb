class ApplicationController < ActionController::Base
	protect_from_forgery

	# Default cancan redirect url
	rescue_from CanCan::AccessDenied do |exception|
		redirect_to root_url, :alert => "You do not have permission to view that page."
	end

	# Initialize cancan
	def current_ability
		@current_ability ||= Ability.new(current_user, params, consignd_session_id, session)
	end

	def consignd_session_id
		@consignd_session_id ||= SecureRandom.random_number(2_147_483_646)
	end
end

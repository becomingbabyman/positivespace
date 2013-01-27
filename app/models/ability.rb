class Ability
	include CanCan::Ability

	def initialize(user, params, session_id, session)
		# Define abilities for the passed in user here.

		user ||= User.new # guest user (not logged in)

		######################################################
		# Registered Users
		######################################################
		if user.persisted?
			can [:edit, :update], User do |u|
				u == user
			end
		end
		######################################################
		# Guest users / Everybody
		######################################################



		######################################################
		# Aliases
		######################################################
		alias_action :update, :destroy, :to => :modify
	end
end
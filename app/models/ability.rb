class Ability
	include CanCan::Ability

	def initialize(user, params, session_id, session)
		# Define abilities for the passed in user here.

		user ||= User.new # guest user (not logged in)

		######################################################
		# Registered Users
		######################################################
		if user.persisted?
			can [:show], Message do |m|
				m.from == user or m.to == user
			end
			can [:modify], Message do |m|
				(m.created_at + 15.minutes > DateTime.now.utc) and user.editor?(m)
			end


			can [:update], User do |u|
				user.editor?(u)
			end
		end
		######################################################
		# Guest users / Everybody
		######################################################
		can [:create], Message


		######################################################
		# Aliases
		######################################################
		alias_action :update, :destroy, :to => :modify
	end
end

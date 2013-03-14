class Ability
	include CanCan::Ability

	def initialize(user, params, session_id, session)
		# Define abilities for the passed in user here.

		user ||= User.new # guest user (not logged in)

		######################################################
		# Registered Users
		######################################################
		if user.persisted?
			can [:create, :update], Image do |image|
				user.editor? image.attachable
			end

			can [:index], Message do
				params[:user_id] == user.id
			end
			can [:show], Message do |m|
				m.from == user or m.to == user
			end

			can [:update], User do |u|
				user.editor?(u)
			end
		end
		######################################################
		# Guest users / Everybody
		######################################################
		can [:create], Message
		can [:modify], Message do |m|
			m.seconds_left_to_edit > 0 and (user.editor?(m) or session_id == m.session_id)
		end

		######################################################
		# Aliases
		######################################################
		alias_action :update, :destroy, :to => :modify
	end
end

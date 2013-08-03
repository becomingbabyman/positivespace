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

			can [:read], Conversation do
				params[:user_id] == 'me' or params[:user_id].to_i == user.id
			end
			can [:update], Conversation do |c|
				user.editor?(c)
			end

			can [:read], Message do
				params[:user_id] == 'me' or params[:user_id].to_i == user.id
			end

			can [:create], Review do
				c = Conversation.find(params[:conversation_id]) and user.member? c
			end
			can [:read], Review do |r|
				user.member?(r)
			end
			can [:update], Review do |r|
				user.editor?(r)
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
			(m.draft? or m.seconds_left_to_edit > 0) and (user.editor?(m) or session_id == m.session_id)
		end

		######################################################
		# Aliases
		######################################################
		alias_action :index, :show, :to => :read
		alias_action :update, :destroy, :to => :modify
	end
end

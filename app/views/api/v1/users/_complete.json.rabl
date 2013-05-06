object @user

extends 'api/v1/users/base'

attributes :body, :location, :personal_url, :created_at, :impressions_count, :state, :likers_count, :followers_count, :mentioners_count
attributes :achievements, :facebook_id, :sign_in_count, :last_sign_in_at, :updated_at, :gender, :birthday, :locale, :timezone, :remaining_invitations_count, :if => lambda { |u| can?(:update, u) }

node :first_name do |user|
	user.first_name
end

node :last_name do |user|
	user.last_name
end

node :can_edit do |user|
	can?(:update, user)
end

node :can_delete do |user|
	can?(:destroy, user)
end

node :accessible_attributes, :if => lambda { |u| can?(:update, u) } do |user|
	User.map_accessible_attributes
end

node :ready_conversations_count, :if => lambda { |u| can?(:update, u) } do |user|
	user.conversations.in_progress.turn(user.id).size
end

node :waiting_conversations_count, :if => lambda { |u| can?(:update, u) } do |user|
	user.conversations.in_progress.not_turn(user.id).size
end

node :ended_conversations_count, :if => lambda { |u| can?(:update, u) } do |user|
	user.conversations.ended.size
end

child :invitation => :invitation do
	child :user => :user do
		extends "api/v1/users/base"
	end
end

node :has_like do |u|
	u.liked_by? current_user if current_user
end

node :has_follow do |u|
	u.followed_by? current_user if current_user
end

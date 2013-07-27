object @user

extends 'api/v1/users/base'

attributes :body, :location, :personal_url, :created_at, :impressions_count, :state, :likers_count, :followers_count, :follows_count, :mentioners_count, :sent_conversations_count, :recieved_conversations_count
attributes :settings, :sign_in_count, :last_sign_in_at, :updated_at, :gender, :birthday, :locale, :timezone, :remaining_invitations_count, :if => lambda { |u| can?(:update, u) }

# TODO: remove this when there is a better/separate space editing UI
node :prompt do |u|
	u.try(:space).try(:prompt)
end

node :first_name do |user|
	user.first_name
end

node :last_name do |user|
	user.last_name
end

node :skills do |u|
	u.skills.pluck(:name)
end

node :interests do |u|
	u.interests.pluck(:name)
end

node :can_edit do |user|
	can?(:update, user)
end

node :can_delete do |user|
	can?(:destroy, user)
end

node :achievements_list, :if => lambda { |u| can?(:update, u) } do |user|
	user.achievements.pluck(:name)
end

node :accessible_attributes, :if => lambda { |u| can?(:update, u) } do |user|
	User.map_accessible_attributes
end

node :ready_conversations_count, :if => lambda { |u| can?(:update, u) } do |user|
	user.conversations.in_progress.turn(user.id).count
end

node :waiting_conversations_count, :if => lambda { |u| can?(:update, u) } do |user|
	user.conversations.in_progress.not_turn(user.id).size
end

node :ended_conversations_count, :if => lambda { |u| can?(:update, u) } do |user|
	user.conversations.ended.size
end

node :relationship do |user|
	user.relationship(current_user)
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

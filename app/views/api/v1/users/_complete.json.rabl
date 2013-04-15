object @user

extends 'api/v1/users/base'

attributes :body, :location, :personal_url, :created_at
attributes :achievements, :facebook_id, :sign_in_count, :last_sign_in_at, :updated_at, :gender, :birthday, :locale, :timezone, :if => lambda { |u| can?(:update, u) }

node :can_edit do |user|
	can?(:update, user)
end

node :can_delete do |user|
	can?(:destroy, user)
end

node :accessible_attributes, :if => lambda { |u| can?(:update, u) } do |user|
	User.map_accessible_attributes
end

node :pending_message_count, :if => lambda { |u| can?(:update, u) } do |user|
	user.recieved_messages.sent.size
end

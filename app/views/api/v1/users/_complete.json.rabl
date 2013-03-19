object @user

extends 'api/v1/users/base'

attributes :body, :location, :personal_url
attributes :achievements, :positive_response, :negative_response, :if => lambda { |u| can?(:update, u) }

node :can_edit do |user|
	can?(:update, user)
end

node :can_delete do |user|
	can?(:destroy, user)
end

node :accessible_attributes, :if => lambda { |u| can?(:update, u) } do |user|
	User.map_accessible_attributes
end

object @user

extends 'api/v1/users/base'

attributes :name, :body, :location, :personal_url
attributes :achievements, :if => lambda { |u| can?(:update, u) }

node :accessible_attributes, :if => lambda { |u| can?(:update, u) } do |user|
	User.map_accessible_attributes
end

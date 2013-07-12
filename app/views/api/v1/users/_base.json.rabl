object @user

attributes :id, :username, :name, :slug, :bio, :body, :location, :personal_url, :facebook_id, :magnetism
attributes :email, :if => lambda { |u| can?(:update, u) }

child :avatar => :avatar do
	extends 'api/v1/images/base'
end

child :space => :space do
	extends 'api/v1/spaces/base'
end

node :uri do |user|
	"#{root_url}api/users/#{user.slug}" rescue nil
end

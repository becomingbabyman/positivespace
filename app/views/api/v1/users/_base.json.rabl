# object @user
cache [root_object, root_object.avatar, root_object.space]

attributes :id, :username, :name, :slug, :bio, :location, :personal_url, :facebook_id, :twitter_id, :twitter_handle, :linkedin_id, :linkedin_profile_url, :show_facebook, :show_twitter, :show_linkedin, :magnetism, :created_at

child :avatar => :avatar do
	extends 'api/v1/images/base'
end

child :space => :space do
	extends 'api/v1/spaces/base'
end

node :uri do |user|
	"#{root_url}api/users/#{user.slug}" rescue nil
end

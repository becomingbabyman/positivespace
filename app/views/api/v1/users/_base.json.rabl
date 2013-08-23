# object @user
cache [root_object, root_object.avatar, root_object.space]

attributes :id, :username, :name, :slug, :bio, :location, :personal_url, :facebook_id, :twitter_id, :twitter_handle, 
	:linkedin_id, :linkedin_profile_url, :github_id, :github_login, :show_facebook, :show_twitter, :show_linkedin, 
	:show_github, :magnetism, :created_at, :updated_at, :impressions_count, :state, :likers_count, :followers_count, :follows_count, 
	:mentioners_count, :sent_conversations_count, :recieved_conversations_count

child :avatar => :avatar do
	extends 'api/v1/images/base'
end

child :space => :space do
	extends 'api/v1/spaces/base'
end

node :uri do |user|
	"#{root_url}api/users/#{user.slug}" rescue nil
end

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
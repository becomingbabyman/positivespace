object @user

attributes :id, :username, :name
attributes :email, :if => lambda { |u| can?(:update, u) }

child :avatar => :avatar do
	extends 'api/v1/images/base'
end

node :uri do |user|
	"#{root_url}api/users/#{user.username}" rescue nil
end

object @user

attributes :id, :username
attributes :email, :if => lambda { |u| can?(:update, u) }

node :uri do |user|
	"#{root_url}api/users/#{user.username}" rescue nil
end

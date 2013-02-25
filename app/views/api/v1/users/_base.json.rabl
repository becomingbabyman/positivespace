object @user

attributes :id, :username

if !@users and @user == current_user
	attributes :email, :achievements
end

node(:uri) do |user|
	"#{root_url}api/#{user.username}" rescue nil
end

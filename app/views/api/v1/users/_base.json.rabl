object @user

attributes :id, :username

if !@users and @user == current_user
	attributes :email
end

node(:url) do |user|
	"#{root_url}api/#{user.username}.json" rescue nil
end

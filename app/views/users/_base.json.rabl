object @user

attributes :id, :username

if @user == current_user
	attributes :email
end

node(:url) do |user|
	"#{root_url}#{user.username}.json" rescue nil
end
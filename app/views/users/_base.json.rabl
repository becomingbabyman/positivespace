object @user

attributes :id, :username

node(:url) do |user|
	"#{root_url}#{user.username}" rescue nil
end

node(:avatar) do |user|
	user.profile.avatar.image.small rescue nil
end

node(:name) do |user|
	user.profile.name rescue nil
end
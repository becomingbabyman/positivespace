object @message

attributes :id, :body, :embed_url, :embed_data

node :user_id do |msg|
	msg.to.id
end

child :from do
	extends 'api/v1/users/base'
end

child :to do
	extends 'api/v1/users/base'
end

node(:uri) do |msg|
	"#{root_url}api/#{msg.to.username}/messages/#{msg.id}" rescue nil
end
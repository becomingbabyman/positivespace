object @message
cache @object

attributes :id, :body, :embed_url, :embed_data, :state, :conversation_id, :created_at

node :user_id do |msg|
	msg.to.id
end

child from: :from do
	extends 'api/v1/users/base'
end

child to: :to do
	extends 'api/v1/users/base'
end

node :uri do |msg|
	"#{root_url}api/#{msg.to.username}/messages/#{msg.id}" rescue nil
end

node :accessible_attributes, :if => lambda { |m| can?(:update, m) } do
	Message.map_accessible_attributes
end

node :total_seconds_to_edit, :if => lambda { |m| can?(:update, m) } do
	Message.total_seconds_to_edit
end

node :seconds_left_to_edit, :if => lambda { |m| can?(:update, m) } do |message|
	message.seconds_left_to_edit
end

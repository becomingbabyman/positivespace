object @conversation

attributes :id, :state, :created_at, :updated_at, :last_message_id, :last_message_from_id, :last_message_body, :prompt

node :user_id do |conversation|
	conversation.to.id
end

# child from: :from do
#	extends 'api/v1/users/base'
# end

# child to: :to do
#	extends 'api/v1/users/base'
# end

child :from => :from do |u|
	attributes :id, :name

	node :avatar do |u|
		{thumb_url: u.avatar.image.thumb.url}
	end
end

child :to => :to do |u|
	attributes :id, :name

	node :avatar do |u|
		{thumb_url: u.avatar.image.thumb.url}
	end
end

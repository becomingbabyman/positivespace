object @conversation

attributes :id, :state, :created_at, :updated_at, :last_message_id, :last_message_from_id, :last_message_body, :prompt

node :user_id do |conversation|
	conversation.to.id
end

node :max_char_count do |conversation|
	conversation.messages.last.max_char_count
end

node :relationship, :if => lambda { |c| (current_user and current_user.editor?(c)) } do |conversation|
	conversation.relationship current_user
end

# child from: :from do
#	extends 'api/v1/users/base'
# end

# child to: :to do
#	extends 'api/v1/users/base'
# end

child :from => :from do |u|
	attributes :id, :name, :username, :slug

	node :avatar do |u|
		{thumb_url: u.avatar.image.thumb.url}
	end
end

child :to => :to do |u|
	attributes :id, :name, :username, :slug

	node :avatar do |u|
		{thumb_url: u.avatar.image.thumb.url}
	end
end

node :partners_id, :if => lambda { |c| (current_user and current_user.editor?(c)) } do |c|
	if current_user.id == c.from_id
		c.to_id
	elsif current_user.id == c.to_id
		c.from_id
	end
end

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

node :my_review, :if => lambda { |c| (current_user and current_user.editor?(c)) } do |conversation|
	partial 'api/v1/reviews/base', object: (current_user.review conversation)
end

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

# child :reviews => :reviews do |u|
#	extends 'api/v1/reviews/base'
# end

node :partners_id, :if => lambda { |c| (current_user and current_user.editor?(c)) } do |c|
	c.partner(current_user).id
end

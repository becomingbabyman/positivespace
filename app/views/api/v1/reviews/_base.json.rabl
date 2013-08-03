object @review

attributes :id, :reviewable_id, :reviewable_type, :user_id, :vote, :rating, :explanation, :created_at, :updated_at

node :conversation_id, :if => lambda { |r| r.reviewable_type == 'Conversation' } do |r|
	r.reviewable_id
end

child :user => :user do |u|
	attributes :id, :name, :username, :slug

	node :avatar do |u|
		{thumb_url: u.avatar.image.thumb.url}
	end
end

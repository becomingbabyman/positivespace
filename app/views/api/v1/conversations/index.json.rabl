object false

node(:total) { |i| @conversations.total_count }
node(:total_pages) { |i| @conversations.num_pages }

child @conversations => :collection do
	cache @conversations
	extends 'api/v1/conversations/base'
end

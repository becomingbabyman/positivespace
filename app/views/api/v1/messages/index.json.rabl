object false

node(:total) { |i| @messages.total_count }
node(:total_pages) { |i| @messages.num_pages }

child @messages => :collection do
	cache @messages
	extends 'api/v1/messages/base'
end

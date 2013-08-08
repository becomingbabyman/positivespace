object false

node(:total) { |i| @messages.total_count }
node(:total_pages) { |i| @messages.num_pages }

child @messages => :collection do
	# cache [@messages, @messages.map { |m| m.to }, @messages.map { |m| m.from }, current_user]
	extends 'api/v1/messages/base'
end

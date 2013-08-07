object false

node(:total) { |i| @reviews.total_count }
node(:total_pages) { |i| @reviews.num_pages }

child @reviews => :collection do
	# cache [@reviews, @reviews.map { |r| r.user }, current_user]
	extends 'api/v1/reviews/base'
end

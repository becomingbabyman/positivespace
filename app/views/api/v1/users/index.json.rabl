object false

node(:total) { |i| @users.total_count }
node(:total_pages) { |i| @users.num_pages }

child @users => :collection do
	cache @users
	extends 'api/v1/users/base'
end

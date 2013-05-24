object false

node(:total) { |i| @users.total_count }
node(:total_pages) { |i| @users.num_pages }
node :query do |i|
	q = {
		page: @users.current_page,
		per: @users.size,
	}
	q[:order] = params[:order] if params[:order]
	q[:following] = params[:following] if params[:following]
	q[:followers] = params[:followers] if params[:followers]
	q
end

child @users => :collection do
	# cache @users
	# extends 'api/v1/users/base'
	extends 'api/v1/users/complete'
end

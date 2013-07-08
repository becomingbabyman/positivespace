object false

node(:total) { |i| @tags.total_count }
node(:total_pages) { |i| @tags.num_pages }
node :query do |i|
	q = {
		page: @tags.current_page,
		per: @tags.size,
	}
	q[:model] = params[:model] if params[:model]
	q[:tag] = params[:tag] if params[:tag]
	q[:q] = params[:q] if params[:q]
	q
end

child @tags => :collection do
	attributes :id, :name
end

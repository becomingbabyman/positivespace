object false

node(:total) { |i| @conversations.total_count }
node(:total_pages) { |i| @conversations.num_pages }
node :query do |i|
	q = {
		page: @conversations.current_page,
		per: @conversations.size,
	}
	q[:user_id] = params[:user_id] if params[:user_id]
	q[:order] = params[:order] if params[:order]
	q[:state] = params[:state] if params[:state]
	q[:turn_id] = params[:turn_id] if params[:turn_id]
	q[:not_turn_id] = params[:not_turn_id] if params[:not_turn_id]
	q
end

child @conversations => :collection do
	cache [@conversations, @conversations.map { |c| c.to }, @conversations.map { |c| c.from }, current_user]
	extends 'api/v1/conversations/base'
end

class Api::V1::ConversationsController < InheritedResources::Base
	belongs_to :user

	respond_to :json
	actions :index, :update

	has_scope :with, :only => :index do |controller, scope, value|
		scope.with(value)
	end
	# only works with an array of 2 user_ids
	has_scope :between, :only => :index, type: :array do |controller, scope, value|
		scope.between(value.first, value.last)
	end
	has_scope :state, :only => :index do |controller, scope, value|
		scope.where(state: value)
	end
	has_scope :page, :only => :index, :default => 1 do |controller, scope, value|
		value.to_i > 0 ? scope.page(value.to_i) : scope.page(1)
	end
	has_scope :per, :only => :index, :default => 10


	before_filter :authenticate_user! #, :except => [:create, :update]
	load_and_authorize_resource


	before_filter :pick_params, :only => [:update]

protected

	def collection
		@conversations = apply_scopes(end_of_association_chain)
	end

	def pick_params
		if conversation = params[:conversation]
			params[:conversation] = pick(conversation, Conversation.accessible_attributes.to_a)
		end
	end
end

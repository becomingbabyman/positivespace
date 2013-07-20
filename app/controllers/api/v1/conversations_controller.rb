class Api::V1::ConversationsController < InheritedResources::Base
	belongs_to :user

	respond_to :json
	actions :index, :show, :update

	has_scope :to, :only => :index do |controller, scope, value|
		scope.to(value)
	end
	has_scope :from, :only => :index do |controller, scope, value|
		scope.from(value)
	end
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
	has_scope :turn_id, :only => :index do |controller, scope, value|
		value == 'me' ? scope.turn(controller.current_user.id) : scope.turn(value.to_i)
	end
	has_scope :not_turn_id, :only => :index do |controller, scope, value|
		value == 'me' ? scope.not_turn(controller.current_user.id) : scope.not_turn(value.to_i)
	end
	has_scope :order, :only => :index do |controller, scope, value|
		scope.order(ActiveRecord::Base::sanitize(value).gsub("'", ""))
	end
	has_scope :page, :only => :index, :default => 1 do |controller, scope, value|
		value.to_i > 0 ? scope.page(value.to_i) : scope.page(1)
	end
	has_scope :per, :only => :index, :default => 10


	before_filter :authenticate_user! #, :except => [:create, :update]
	load_and_authorize_resource


	before_filter :pick_params, :only => [:update]

	def index
		@conversations = apply_scopes(current_user.try(:conversations))
		index!
	end

protected

	def begin_of_association_chain
		if params[:user_id] == 'me'
			@user = current_user
		else
			@user = User.find(params[:user_id])
		end
		@user.conversations
	end

	def collection
		@conversations = apply_scopes(end_of_association_chain).includes(:to, :from)
	end

	def pick_params
		if conversation = params[:conversation]
			params[:conversation] = pick(conversation, Conversation.accessible_attributes.to_a)
		end
	end
end

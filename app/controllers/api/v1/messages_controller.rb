class Api::V1::MessagesController < InheritedResources::Base
	belongs_to :user

	respond_to :json
	actions :show, :index, :create, :update, :destroy

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
	has_scope :conversation_id, :only => :index do |controller, scope, value|
		scope.conversation_id(value.to_i)
	end
	has_scope :order, :only => :index, :default => "created_at ASC" do |controller, scope, value|
		scope.order(ActiveRecord::Base::sanitize(value).gsub("'", ""))
	end
	has_scope :page, :only => :index, :default => 1 do |controller, scope, value|
		value.to_i > 0 ? scope.page(value.to_i) : scope.page(1)
	end
	has_scope :per, :only => :index, :default => 1000

	before_filter :authenticate_user! #, :except => [:create, :update]
	load_and_authorize_resource


	before_filter :pick_params, :only => [:create, :update]


	def create
		@user = User.find(params[:user_id])
		@message = Message.new(params[:message])
		@message.to = @user
		@message.from = current_user
		@message.session_id = positivespace_session_id
		create!
	end

protected

	def begin_of_association_chain
		if params[:user_id] == 'me'
			@user = current_user
		else
			@user = User.find(params[:user_id])
		end
		@user.messages
	end

	def collection
		@messages = apply_scopes(end_of_association_chain)
	end

	def pick_params
		if message = params[:message]
			params[:message] = pick(message, Message.accessible_attributes.to_a)
		end
	end
end

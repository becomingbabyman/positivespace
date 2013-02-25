class Api::V1::MessagesController < InheritedResources::Base
	belongs_to :user

	respond_to :json
	actions :show, :index, :create


	has_scope :page, :only => :index, :default => 1 do |controller, scope, value|
		value.to_i > 0 ? scope.page(value.to_i) : scope.page(1)
	end
	has_scope :per, :only => :index, :default => 10


	before_filter :authenticate_user!, :except => [:create]
	load_and_authorize_resource


	def create
		@user = User.find(params[:user_id])
		@message = Message.new(params[:message])
		@message.to = @user
		@message.save!
	end

protected

	def collection
		@messages = apply_scopes(end_of_association_chain)
	end
end

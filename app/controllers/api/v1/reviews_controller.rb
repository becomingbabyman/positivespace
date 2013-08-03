class Api::V1::ReviewsController < InheritedResources::Base
	belongs_to :conversation

	respond_to :json
	actions :index, :create, :update

	has_scope :user_id, :only => :index do |controller, scope, value|
		scope.user_id(value.to_i)
	end
	has_scope :order, :only => :index, :default => "created_at ASC" do |controller, scope, value|
		scope.order(ActiveRecord::Base::sanitize(value).gsub("'", ""))
	end
	has_scope :page, :only => :index, :default => 1 do |controller, scope, value|
		value.to_i > 0 ? scope.page(value.to_i) : scope.page(1)
	end
	has_scope :per, :only => :index, :default => 10

	before_filter :authenticate_user! #, :except => [:create, :update]
	load_and_authorize_resource

	before_filter :pick_params, :only => [:create, :update]

	def create
		@review.user = current_user
		create!
	end

protected

	def collection
		@reviews = apply_scopes(end_of_association_chain)
	end

	def pick_params
		if review = params[:review]
			params[:review] = pick(review, Review.accessible_attributes.to_a)
		end
	end
end

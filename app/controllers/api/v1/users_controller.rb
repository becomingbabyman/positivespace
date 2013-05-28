class Api::V1::UsersController < InheritedResources::Base
	respond_to :json
	actions :index, :show, :update, :metrics

	has_scope :login, :only => :index do |controller, scope, value|
		scope.where("users.email = ? OR users.username = ?", value.downcase, value.downcase)
	end
	has_scope :email, :only => :index do |controller, scope, value|
		scope.where("users.email = ?", value.downcase)
	end
	has_scope :username, :only => :index do |controller, scope, value|
		scope.where("users.username = ?", value.downcase)
	end
	has_scope :id, :only => :index do |controller, scope, value|
		scope.where("users.id = ?", value.downcase)
	end
	has_scope :following, :only => :index do |controller, scope, value|
		scope.joins("INNER JOIN follows ON follows.followable_id = users.id AND follows.followable_type = 'User'").where("follows.follower_type = 'User' AND follows.follower_id = ?", value.to_i)
	end
	has_scope :followers, :only => :index do |controller, scope, value|
		scope.joins(:follows).where("follows.followable_id = ? AND follows.followable_type = 'User' AND follows.follower_type = 'User'", value.to_i)
	end
	has_scope :publishable, :only => :index, type: :boolean, default: true do |controller, scope, value|
		scope.where("users.body IS NOT NULL")
	end
	has_scope :complete, :only => :index, type: :boolean do |controller, scope, value|
		scope.where("users.body IS NOT NULL AND users.location IS NOT NULL AND users.personal_url IS NOT NULL")
	end
	has_scope :endorsed, :only => :index, type: :boolean, default: true do |controller, scope, value|
		scope.endorsed
	end
	has_scope :order, :only => :index do |controller, scope, value|
		if value == "RANDOM()"
			scope.order("RANDOM()")
		else
			scope.order("users.#{ActiveRecord::Base::sanitize(value).gsub("'", "")}")
		end
	end
	has_scope :page, :only => :index, :default => 1 do |controller, scope, value|
		value.to_i > 0 ? scope.page(value.to_i) : scope.page(1)
	end
	has_scope :per, :only => :index, :default => Proc.new { |c| c.session[:users_per] ? c.session[:users_per] : 10 } do |controller, scope, value|
		controller.session[:users_per] = value.to_i if (1..20) === value.to_i
		controller.session[:users_per] ? scope.per(controller.session[:users_per]) : scope.per(10)
		# TODO: add throttling to this to make it a little harder to get all the emails out of the DB
		# scope.per(1)
	end

	before_filter :authenticate_user!, only: [:show], :if => lambda { params[:id] == 'me' }
	before_filter :authenticate_user!, only: [:metrics]
	load_and_authorize_resource :only => [:update]

	before_filter :pick_params, :only => [:update]

	def index
		if params[:q]
			params[:per] = 10
			@users = User.search(params)
			render "search"
		else
			index!
		end
	end

	def show
		@user = (params[:id] == 'me' ? current_user : User.find(params[:id]))
		impressionist @user if @user != current_user
		show!
	end

	def metrics
		@user = current_user
		render json: @user.metrics(params).to_json, template: false
	end

protected

	def collection
		@users ||= apply_scopes(end_of_association_chain) unless params[:q]
	end

	def pick_params
		if user = params[:user]
			params[:user] = pick(user, User.accessible_attributes.to_a)
		end
	end
end

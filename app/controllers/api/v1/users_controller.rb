class Api::V1::UsersController < InheritedResources::Base
	respond_to :json
	actions :index, :show

	has_scope :login, :only => :index do |controller, scope, value|
		scope.where("email = ? OR username = ?", value.downcase, value.downcase)
	end
	has_scope :email, :only => :index do |controller, scope, value|
		scope.where("email = ?", value.downcase)
	end
	has_scope :username, :only => :index do |controller, scope, value|
		scope.where("username = ?", value.downcase)
	end
	has_scope :id, :only => :index do |controller, scope, value|
		scope.where("id = ?", value.downcase)
	end
	has_scope :order, :only => :index do |controller, scope, value|
		scope.order(value)
	end
	has_scope :page, :only => :index, :default => 1 do |controller, scope, value|
		value.to_i > 0 ? scope.page(value.to_i) : scope.page(1)
	end
	has_scope :per, :only => :index, :default => Proc.new { |c| c.session[:users_per] ? c.session[:users_per] : 10 } do |controller, scope, value|
		# controller.session[:users_per] = value.to_i if (1..100) === value.to_i
		# controller.session[:users_per] ? scope.per(controller.session[:users_per]) : scope.per(10)
		# TODO: add throttling to this to make it a little harder to get all the emails out of the DB
		scope.per(1)
	end

	before_filter :authenticate_user!, only: [:show], :if => lambda { params[:id] == 'me' }

	load_and_authorize_resource :only => [:edit, :update]

	def show
		@user = (params[:id] == 'me' ? current_user : User.find(params[:id]))
		show!
	end

protected

	def collection
		@users ||= apply_scopes(end_of_association_chain)
	end
end
class Api::V1::TagsController < InheritedResources::Base
	defaults resource_class: ActsAsTaggableOn::Tag

	respond_to :json
	actions :index

	# has_scope :model, :only => :index, :default => 'user' do |controller, scope, value|
	#	case value
	#	when 'user'

	#	end
	# end
	# has_scope :tag, :only => :index, :default => 'skills' do |controller, scope, value|
	#	case value
	#	when 'skills'

	#	end
	# end
	has_scope :q, :only => :index do |controller, scope, value|
		scope.where("name LIKE ?", "%#{value}%")
	end
	has_scope :page, :only => :index, :default => 1 do |controller, scope, value|
		value.to_i > 0 ? scope.page(value.to_i) : scope.page(1)
	end
	has_scope :per, :only => :index, :default => 10

protected
	def collection
		@tags ||= apply_scopes(end_of_association_chain)
	end
end

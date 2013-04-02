object @conversation

attributes :id, :state, :created_at, :updated_at

node :user_id do |con|
	con.to.id
end

child from: :from do
	extends 'api/v1/users/base'
end

child to: :to do
	extends 'api/v1/users/base'
end

# child :from do |u|
#	attributes :name

#	child :avatar => :avatar do
#		extends 'api/v1/images/base'
#	end
# end

# child :to do |u|
#	attributes :name

#	child :avatar => :avatar do
#		extends 'api/v1/images/base'
#	end
# end

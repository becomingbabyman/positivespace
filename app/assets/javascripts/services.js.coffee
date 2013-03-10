psServices = angular.module 'psServices', ['ngResource']


#####################################################
#                                                   #
#  NOTE:                                            #
#  Be sure to under_score rather than caemelCase    #
#  a resource's params. This allows us to keep the  #
#  params pefectly in sync with what is returned    #
#  and expected by the API.                         #
#                                                   #
#####################################################

psServices.factory 'User', ['$resource', ($resource) ->
	User = $resource "/api/users/:list_ctrl/:id/:doc_ctrl",
		id: '@id'
		list_ctrl: '@list_ctrl'
		doc_ctrl: '@doc_ctrl'
	,
		current:
			method: 'GET'
			params:
				list_ctrl: 'me'

		# email: String
		# username: String
		# password: String
		register:
			method: 'POST'
			params:
				remember_me: true

		# login: String - email or username
		# password: String
		login:
			method: 'POST'
			params:
				list_ctrl: 'sign_in'
				remember_me: true

		logout:
			method: 'DELETE'
			params:
				list_ctrl: 'sign_out'

		# login: String - email or username
		resetPassword:
			method: 'POST'
			params:
				list_ctrl: 'password'

		# password: String - password
		# password_confirmation: String - password
		# reset_password_token: String - token from the email
		updatePassword:
			method: 'PUT'
			params:
				list_ctrl: 'password'

		update:
			method: 'PUT'

	User::save = (success=null, error=null) ->
		if @id?
			@$update(success, error)


	User
]


psServices.factory 'Message', ['$resource', ($resource) ->
	Message = $resource "/api/users/:user_id/messages/:list_ctrl/:id/:doc_ctrl",
		user_id: '@user_id'
		id: '@id'
		list_ctrl: '@list_ctrl'
		doc_ctrl: '@doc_ctrl'
	,
		update:
			method: 'PUT'

	Message::save = (success=null, error=null) ->
		if @id?
			@$update(success, error)
		else
			@$save(success, error)

	Message
]

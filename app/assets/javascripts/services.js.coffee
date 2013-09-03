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

psServices.factory 'Conversation', ['$resource', ($resource) ->
	Conversation = $resource "/api/users/:user_id/conversations/:list_ctrl/:id/:doc_ctrl",
		user_id: '@user_id'
		id: '@id'
		list_ctrl: '@list_ctrl'
		doc_ctrl: '@doc_ctrl'
	,
		query:
			method: 'GET'
			isArray: false

		update:
			method: 'PUT'

	Conversation::save = (success=null, error=null) ->
		if @id?
			@$update(success, error)
		else
			@$save(success, error)

	Conversation
]


psServices.factory 'Message', ['$resource', ($resource) ->
	Message = $resource "/api/users/:user_id/messages/:list_ctrl/:id/:doc_ctrl",
		user_id: '@user_id'
		id: '@id'
		list_ctrl: '@list_ctrl'
		doc_ctrl: '@doc_ctrl'
	,
		query:
			method: 'GET'
			isArray: false

		update:
			method: 'PUT'

	Message::save = (success=null, error=null) ->
		if @id?
			@$update(success, error)
		else
			@$save(success, error)

	Message
]


psServices.factory 'Review', ['$resource', ($resource) ->
	Review = $resource "/api/conversations/:conversation_id/reviews/:list_ctrl/:id/:doc_ctrl",
		conversation_id: '@conversation_id'
		id: '@id'
		list_ctrl: '@list_ctrl'
		doc_ctrl: '@doc_ctrl'
	,
		query:
			method: 'GET'
			isArray: false

		update:
			method: 'PUT'

	Review::save = (success=null, error=null) ->
		if @id?
			@$update(success, error)
		else
			@$save(success, error)

	Review
]


psServices.factory 'Space', ['$resource', ($resource) ->
	Space = $resource "/api/spaces/:list_ctrl/:id/:doc_ctrl",
		id: '@id'
		list_ctrl: '@list_ctrl'
		doc_ctrl: '@doc_ctrl'
	,
		query:
			method: 'GET'
			isArray: false

		update:
			method: 'PUT'

	Space::save = (success=null, error=null) ->
		if @id?
			@$update(success, error)
		else
			@$save(success, error)

	Space
]



psServices.factory 'User', ['$resource', ($resource) ->
	User = $resource "/api/users/:list_ctrl/:id/:doc_ctrl",
		id: '@id'
		list_ctrl: '@list_ctrl'
		doc_ctrl: '@doc_ctrl'
	,
		query:
			method: 'GET'
			isArray: false

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

		metrics:
			method: 'GET'
			isArray: false
			params:
				list_ctrl: 'metrics'
				days_ago: 0
				days_range: 7
				intervals: 7

	User::save = (success=null, error=null) ->
		if @id?
			@$update(success, error)

	User
]


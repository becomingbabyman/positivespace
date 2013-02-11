psServices = angular.module 'psServices', ['ngResource']

psServices.factory 'User', ['$resource', ($resource) ->
	User = $resource "/users/:listCtrl:id/:docCtrl.json", 
		id: '@id'
		listCtrl: '@listCtrl'
		docCtrl: '@docCtrl'
	,
		current:
			method: 'GET'
			params:
				listCtrl: 'me'

		# email: String
		# username: String
		# password: String
		register:
			method: 'POST'

		# login: String - email or username
		# password: String
		login:
			method: 'POST'
			params:
				listCtrl: 'sign_in'

		logout:
			method: 'DELETE'
			params:
				listCtrl: 'sign_out'

		# login: String - email or username
		resetPassword:
			method: 'POST'
			params:
				listCtrl: 'password'
	User
]
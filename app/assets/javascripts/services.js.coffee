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

		# TODO: this should alternatively accept a username and respond with the @domain.com of the the email address it sent the reset code to
		# email: String
		resetPassword:
			method: 'POST'
			params:
				listCtrl: 'password'
	User
]
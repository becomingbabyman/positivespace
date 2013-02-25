psServices = angular.module 'psServices', ['ngResource']


psServices.factory 'User', ['$resource', ($resource) ->
	User = $resource "api/users/:listCtrl/:id/:docCtrl",
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
			params:
				remember_me: true

		# login: String - email or username
		# password: String
		login:
			method: 'POST'
			params:
				listCtrl: 'sign_in'
				remember_me: true

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


psServices.factory 'Message', ['$resource', ($resource) ->
	Message = $resource "api/users/:userId/messages/:listCtrl/:id/:docCtrl",
		userId: '@userId'
		id: '@id'
		listCtrl: '@listCtrl'
		docCtrl: '@docCtrl'
	, {}

	Message
]

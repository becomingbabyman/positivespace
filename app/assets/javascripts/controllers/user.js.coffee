ps.controller "UsersLoginCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
]


ps.controller "UsersRegisterCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
]


ps.controller "UserPasswordEditCtrl", ["$scope", "$location", "$routeParams", "User", ($scope, $location, $routeParams, User) ->
	$scope.app.show.noChrome()

	$scope.psw = {password: '', passwordConfirmation: ''}

	$scope.updatePassword = ->
		User.updatePassword
			user:
				password: $scope.psw.password
				password_confirmation: $scope.psw.passwordConfirmation
				reset_password_token: $routeParams.reset_password_token
			(data) ->
				$scope.app.flash 'success', "Cool, your password has been updated and you are now logged in."
				$scope.app.currentUser = User.current()
				$location.path('/')
			(error) ->
				$scope.app.flash 'error', error.data.errors
]


ps.controller "UsersShowCtrl", ["$scope", "$routeParams", "$timeout", "User", "Message", ($scope, $routeParams, $timeout, User, Message) ->
	$scope.user = User.get({id: $routeParams.user_id})
	$scope.myMessage = new Message {user_id: $routeParams.user_id}

	$scope.submitMyMessage = ->
		success = (data) ->
			$scope.app.flash 'success', 'Great, your message has been sent.'
		error = (error) ->
			$scope.app.flash 'error', error.data.errors
		$scope.myMessage.save success, error
]


ps.controller "UsersSettingsCtrl", ["$scope", "User", ($scope, User) ->
]

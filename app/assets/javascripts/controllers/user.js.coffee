ps.controller "UsersLoginCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
]

ps.controller "UsersRegisterCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
]

ps.controller "UsersShowCtrl", ["$scope", "$routeParams", "$timeout", "User", "Message", ($scope, $routeParams, $timeout, User, Message) ->
	$scope.user = User.get({id: $routeParams.user_id})
	$scope.myMessage = new Message {user_id: $routeParams.user_id}

	$scope.submitMyMessage = ->
		success = (data) ->
			$scope.app.flash 'success', 'Great, your message will be sent shortly.'
		error = (error) ->
			$scope.app.flash 'error', error.data.errors
		$scope.myMessage.save success, error
]

ps.controller "UsersSettingsCtrl", ["$scope", "User", ($scope, User) ->
]

ps.controller "UsersLoginCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
]

ps.controller "UsersRegisterCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
]

ps.controller "UsersShowCtrl", ["$scope", "$routeParams", "User", "Message", ($scope, $routeParams, User, Message) ->
	$scope.user = User.get({id: $routeParams.user_id})
	$scope.myMessage = new Message {user_id: $routeParams.user_id}

	$scope.submitMyMessage = ->
		success = (data) ->
			$scope.app.flash 'success', 'Great, your message has been sent.'
		error = (error) ->
			$scope.app.flash 'error', error.data.errors
		$scope.myMessage.save success, error
]

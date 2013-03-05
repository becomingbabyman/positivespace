ps.controller "UsersLoginCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
]

ps.controller "UsersRegisterCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
]

ps.controller "UsersShowCtrl", ["$scope", "$routeParams", "$timeout", "User", "Message", ($scope, $routeParams, $timeout, User, Message) ->
	$scope.user = User.get({id: $routeParams.user_id})
	$scope.myMessage = new Message {user_id: $routeParams.user_id}
	$scope.percentBeforeSend = 100
	$scope.prevSecondsLeftToEdit = 99999999

	$scope.submitMyMessage = ->
		success = (data) ->
			$scope.app.flash 'success', 'Great, your message will be sent shortly.'
		error = (error) ->
			$scope.app.flash 'error', error.data.errors
		$scope.myMessage.save success, error

	# TODO: Rethink this. Should a user really be able to edit a message? And is this the best way to allow it?
	$scope.$watch 'myMessage.seconds_left_to_edit', (value) ->
		interval = 3.0
		if value > 0 and value < $scope.prevSecondsLeftToEdit - (interval - 0.001)
			$scope.roundedSecondsLeftToEdit = Math.floor($scope.myMessage.seconds_left_to_edit)
			$scope.prevSecondsLeftToEdit = value
			$timeout () ->
				$scope.myMessage.seconds_left_to_edit = value - interval
				$scope.percentBeforeSend = ($scope.myMessage.seconds_left_to_edit / $scope.myMessage.total_seconds_to_edit) * 100
			, (interval*1000)
]

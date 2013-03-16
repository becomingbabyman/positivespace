ps.controller "MessagesInboxCtrl", ["$scope", "$location", "$timeout", "Message", ($scope, $location, $timeout, Message) ->
	$scope.myMessage = {}

	$scope.$watch 'myMessage.body', (value) ->
		$scope.remainingChars = 250 - (if value? then value.length else 0)

	$scope.$watch 'app.currentUser.id', (id) ->
		if id?
			$scope.messages = Message.query {user_id: id, state: 'pending'}, (data) ->
				if data.length > 0
					$scope.myMessage = new Message {user_id: data[0].from.id}
		else
			# user must log in to view inbox
			$location.path('/login')

	$scope.endConvo = ->
		el = angular.element('.message').first()
		el.addClass 'animated bounceOutLeft'
		$timeout ->
			$scope.messages = $scope.messages.splice 1
		, 500

	$scope.continueConvo = ->
		el = angular.element('.message').first()
		el.addClass 'animated bounceOutRight'
		$timeout ->
			$scope.messages = $scope.messages.splice 1
		, 500


	$scope.reply = ->
		success = (data) ->
			$scope.app.flash 'success', 'Great, your message has been sent.'
			$scope.continueConvo()
			if $scope.messages.length > 0
				$scope.myMessage = new Message {user_id: $scope.messages[0].from.id}
		error = (error) ->
			$scope.app.flash 'error', error.data.errors
		$scope.myMessage.save success, error
]


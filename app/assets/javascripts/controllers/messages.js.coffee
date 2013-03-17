ps.controller "MessagesInboxCtrl", ["$scope", "$location", "$timeout", "Message", ($scope, $location, $timeout, Message) ->
	$scope.myMessage = {}

	$scope.$watch 'myMessage.body', (value) ->
		$scope.remainingChars = 250 - (if value? then value.length else 0)

	$scope.$watch 'app.currentUser.id', (id) ->
		if id?
			$scope.messages = Message.query {user_id: id, state: 'pending'}, (data) ->
				$scope.prepareNextMessage(data)
		else
			# user must log in to view inbox
			$location.path('/login')

	$scope.endConvo = ->
		el = angular.element('.message').first()
		el.addClass 'animated bounceOutLeft'
		$timeout ->
			$scope.messages = $scope.messages.splice 1
			$scope.prepareNextMessage()
		, 500

	$scope.continueConvo = ->
		el = angular.element('.message').first()
		el.addClass 'animated bounceOutRight'
		$timeout ->
			$scope.messages = $scope.messages.splice 1
			$scope.prepareNextMessage()
		, 500

	$scope.prepareNextMessage = (messages = $scope.messages) ->
		if messages.length > 0 and messages[0].from?
			$scope.myMessage = new Message {user_id: messages[0].from.id}
			angular.element("#response_body").focus()

	$scope.reply = ->
		success = (data) ->
			$scope.app.flash 'success', 'Great, your message has been sent.'
			$scope.continueConvo()
		error = (error) ->
			$scope.app.flash 'error', error.data.errors
		$scope.myMessage.save success, error
]


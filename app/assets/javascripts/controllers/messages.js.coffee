ps.controller "MessagesInboxCtrl", ["$scope", "$routeParams", "$location", "$timeout", "Message", "Conversation", ($scope, $routeParams, $location, $timeout, Message, Conversation) ->

	$scope.app.dcu.promise.then (user) ->
		$scope.conversations = Conversation.query {user_id: user.id}
	, (error) ->
		# user must log in to view inbox
		$location.path('/login')


	# $scope.myMessage = {}
	# $scope.currentThread = []

	# $scope.$watch 'myMessage.body', (value) ->
	#	$scope.remainingChars = 250 - (if value? then value.length else 0)

	# $scope.$watch 'app.currentUser.id', (id) ->
	#	if id?
	#		$scope.messages = Message.query {user_id: id, state: 'sent'}, (data) ->
	#			$scope.prepareFirstMessage(data)
	#	else
	#		# user must log in to view inbox
	#		$location.path('/login')

	# $scope.endConvo = ->
	#	el = angular.element('.message').first()
	#	el.addClass 'animated bounceOutLeft'
	#	$timeout ->
	#		$scope.messages = $scope.messages.splice 1
	#		$scope.prepareFirstMessage()
	#	, 500

	# $scope.continueConvo = ->
	#	el = angular.element('.message').first()
	#	el.addClass 'animated bounceOutRight'
	#	$timeout ->
	#		$scope.messages = $scope.messages.splice 1
	#		$scope.prepareFirstMessage()
	#	, 500

	# $scope.prepareFirstMessage = (messages = $scope.messages) ->
	#	if messages.length > 0 and message = messages[0]
	#		$scope.currentMessage = new Message messages[0]
	#		$scope.myMessage = new Message {user_id: message.from.id}
	#		angular.element("#response_body").focus()
	#		$scope.currentThread = Message.query {user_id: $scope.app.currentUser.id, with: message.from.id}, (messages) ->
	#			$scope.lastMsgInThread = (_.last(messages).id == $scope.currentMessage.id)
	#	else
	#		$scope.currentMessage = null
	#		$scope.currentThread = []

	# $scope.save = (state_event = null) ->
	#	success = (data) ->
	#		$scope.app.flash 'success', 'Great, your message has been sent.'
	#		$scope.continueConvo()
	#	error = (error) ->
	#		$scope.app.flash 'error', error.data.errors
	#	if state_event? then $scope.myMessage.state_event = state_event
	#	$scope.myMessage.save success, error
]


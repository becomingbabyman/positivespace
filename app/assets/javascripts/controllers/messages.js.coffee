ps.controller "MessagesInboxCtrl", ["$scope", "$routeParams", "$location", "$timeout", "Message", "Conversation", ($scope, $routeParams, $location, $timeout, Message, Conversation) ->
	$scope.conversations = []
	$scope.currentMsg = {}
	$scope.currentMsgs = []
	$scope.myMessage = {}

	# Initialize
	$scope.app.dcu.promise.then (user) ->
		$scope.conversations = Conversation.query {user_id: user.id}
		$scope.currentMsg = Message.get {user_id: user.id, id: $routeParams.message_id} if $routeParams.message_id
	, (error) ->
		# user must log in to view inbox
		$location.path('/login')
		$scope.app.flash 'info', "Sorry, we don't know whose inbox to show you. Please log in."

	$scope.$watch 'currentMsg.conversation_id', (id) ->
		# console.log id
		if id?
			$scope.app.dcu.promise.then (user) ->
				$scope.currentMsgs = Message.query {user_id: user.id, conversation_id: id}, (messages) ->
					$scope.lastMsg = _.last(messages)
					$scope.myMessage = new Message {user_id: $scope.lastMsg.from.id}

	$scope.selectConversation = (conversation) ->
		$scope.app.show.loading = true
		$scope.app.dcu.promise.then (user) ->
			$scope.currentMsgs = Message.query {user_id: user.id, conversation_id: conversation.id}, (messages) ->
				$scope.lastMsg = _.last(messages)
				$scope.currentMsg = $scope.lastMsg
				$scope.myMessage = new Message {user_id: $scope.lastMsg.from.id}
				$scope.app.show.loading = false
				# $location.search("message_id", $scope.lastMsg.from.id)


	$scope.$watch 'myMessage.body', (value) ->
		$scope.remainingChars = 250 - (if value? then value.length else 0)

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
	#		$scope.currentMsg = new Message messages[0]
	#		$scope.myMessage = new Message {user_id: message.from.id}
	#		angular.element("#response_body").focus()
	#		$scope.currentThread = Message.query {user_id: $scope.app.currentUser.id, with: message.from.id}, (messages) ->
	#			$scope.lastMsgInThread = (_.last(messages).id == $scope.currentMsg.id)
	#	else
	#		$scope.currentMsg = null
	#		$scope.currentThread = []

	$scope.save = (state_event = null) ->
		console.log 'wat'
		success = (data) ->
			$scope.app.flash 'success', 'Great, your message has been sent.'
			# $scope.continueConvo()
		error = (error) ->
			$scope.app.flash 'error', error.data.errors
		if state_event? then $scope.myMessage.state_event = state_event
		$scope.myMessage.save success, error
]


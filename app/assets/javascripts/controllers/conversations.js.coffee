ps.controller "ConversationsIndexCtrl", ["$scope", "$routeParams", "$location", "$timeout", "Message", "Conversation", ($scope, $routeParams, $location, $timeout, Message, Conversation) ->
	$scope.conversations = []

	# Initialize
	$scope.app.dcu.promise.then (user) ->
		$scope.conversations = Conversation.query {user_id: user.id}
	, (error) ->
		# user must log in to view conversations
		$location.path('/login')
		$scope.app.flash 'info', "Sorry, we don't know whose conversations to show you. Please log in."
]


ps.controller "ConversationsShowCtrl", ["$scope", "$routeParams", "$location", "$timeout", "Message", "Conversation", ($scope, $routeParams, $location, $timeout, Message, Conversation) ->
	# $scope.conversations = []
	$scope.conversation = {}
	$scope.message = {}
	$scope.messages = []
	$scope.myMessage = {}
	$scope.lastMsg = {}
	$scope.show = {conversation: false}

	# Initialize
	$scope.app.dcu.promise.then (user) ->
		$scope.conversation = Conversation.get {user_id: user.id, id: $routeParams.id}, (conversation) ->
			$scope.show.conversation = true if conversation.state == 'ended'
			$scope.myMessage = new Message {user_id: conversation.partners_id, conversation_id: $routeParams.id}
		$scope.message = Message.get {user_id: user.id, id: $routeParams.message_id} if $routeParams.message_id
		$scope.messages = Message.query {user_id: user.id, conversation_id: $routeParams.id}, (messages) ->
			$scope.lastMsg = _.last(messages)
			$scope.message = $scope.lastMsg unless $routeParams.message_id
	, (error) ->
		# user must log in to view a conversation
		$location.path('/login')
		$scope.app.flash 'info', "Please log in to view this conversation."


	$scope.$watch 'myMessage.body', (value) ->
		$scope.remainingChars = 250 - (if value? then value.length else 0)

	$scope.end = ->
		if window.confirm 'This conversation is finished.'
			$scope.conversation.state_event = 'end'
			$scope.conversation.save (conversation) ->
				$scope.app.currentUser.ready_conversations_count -= 1
				$scope.app.currentUser.ended_conversations_count += 1

	# $scope.continueConvo = ->
	#	el = angular.element('.message').first()
	#	el.addClass 'animated bounceOutRight'
	#	$timeout ->
	#		$scope.messages = $scope.messages.splice 1
	#		$scope.prepareFirstMessage()
	#	, 500

	$scope.save = (state_event = null) ->
		success = (data) ->
			$scope.app.flash 'success', 'Great, your message has been sent.'
			if data.state == 'sent'
				$scope.messages.push $scope.myMessage
				$scope.lastMsg = $scope.myMessage
				$scope.message = $scope.myMessage
				$scope.app.currentUser.ready_conversations_count -= 1
				$scope.app.currentUser.waiting_conversations_count += 1
				$scope.conversation = new Conversation data.conversation
		error = (error) ->
			$scope.app.flash 'error', error.data.errors
		if state_event? then $scope.myMessage.state_event = state_event
		$scope.myMessage.save success, error
]

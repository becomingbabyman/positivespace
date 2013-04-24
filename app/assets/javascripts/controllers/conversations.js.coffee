ps.controller "ConversationsIndexCtrl", ["$scope", "$routeParams", "$location", "$timeout", "Message", "Conversation", ($scope, $routeParams, $location, $timeout, Message, Conversation) ->
	$scope.conversations = []
	$scope.app.meta.title = "My Conversations"
	$scope.selectedFilter = 'ready'

	# Initialize
	$scope.app.dcu.promise.then (user) ->
		$scope.conversations = Conversation.query {user_id: user.id, state: 'in_progress', turn_id: user.id, order: "updated_at DESC", per: 100}, ->
			analytics.track 'view conversations success',
				user_id: user.id
				user_name: user.name
				readyConversationsCount   : user.ready_conversations_count
				endedConversationsCount   : user.ended_conversations_count
				waitingConversationsCount : user.waiting_conversations_count
	, (error) ->
		# user must log in to view conversations
		$location.path('/login')
		$scope.app.flash 'info', "Sorry, we don't know whose conversations to show you. Please log in."
		analytics.track 'view conversations error',
			error: 'not logged in'

	$scope.filter = (option) ->
		$scope.app.dcu.promise.then (user) ->
			if option != $scope.selectedFilter
				switch option
					when 'ready' then $scope.conversations = Conversation.query {user_id: user.id, state: 'in_progress', turn_id: user.id, order: "updated_at ASC", per: 100}
					when 'waiting' then $scope.conversations = Conversation.query {user_id: user.id, state: 'in_progress', not_turn_id: user.id, order: "updated_at DESC", per: 100}
					when 'ended' then $scope.conversations = Conversation.query {user_id: user.id, state: 'ended', order: "updated_at DESC", per: 100}
				$scope.selectedFilter = option
				analytics.track "conversations filter by #{option}"
			else
				$scope.conversations = Conversation.query {user_id: user.id, order: "updated_at DESC", per: 100}
				$scope.selectedFilter = null
				analytics.track "conversations filter by all"

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
			$scope.app.meta.title = "Conversation · #{conversation.from.name} -> #{conversation.to.name}"
			analytics.track 'view conversation success',
				href: window.location.href
				routeId: $routeParams.id
				conversationId: conversation.id
				conversationPrompt: $scope.conversation.prompt
				toId: conversation.to.id
				toName: conversation.to.name
				fromId: conversation.from.id
				fromName: conversation.from.name
		$scope.message = Message.get {user_id: user.id, id: $routeParams.message_id} if $routeParams.message_id
		$scope.messages = Message.query {user_id: user.id, conversation_id: $routeParams.id, per: 100}, (messages) ->
			$scope.lastMsg = _.last(messages)
			$scope.message = $scope.lastMsg unless $routeParams.message_id
	, (error) ->
		# user must log in to view a conversation
		$location.path('/login')
		$scope.app.flash 'info', "Please log in to view this conversation."
		analytics.track 'view conversation error',
			routeId: $routeParams.id
			error: 'not logged in'


	$scope.$watch 'myMessage.body', (value) ->
		$scope.remainingChars = 250 - (if value? then value.length else 0)

	$scope.end = ->
		if window.confirm 'This conversation is finished.'
			$scope.conversation.state_event = 'end'
			$scope.conversation.save (conversation) ->
				$scope.app.currentUser.ready_conversations_count -= 1
				$scope.app.currentUser.ended_conversations_count += 1
				analytics.track 'end conversation success',
					href: window.location.href
					routeId: $routeParams.id
					conversationId: $scope.conversation.id
					conversationPrompt: $scope.conversation.prompt
					toId: $scope.conversation.to.id
					toName: $scope.conversation.to.name
					fromId: $scope.conversation.from.id
					fromName: $scope.conversation.from.name
			, (error) ->
				analytics.track 'end conversation error',
					href: window.location.href
					routeId: $routeParams.id
					conversationId: $scope.conversation.id
					conversationPrompt: $scope.conversation.prompt
					toId: $scope.conversation.to.id
					toName: $scope.conversation.to.name
					fromId: $scope.conversation.from.id
					fromName: $scope.conversation.from.name
					error: JSON.stringify(error)


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

				analytics.track 'message conversation success',
					href: window.location.href
					routeId: $routeParams.id
					conversationId: $scope.conversation.id
					conversationPrompt: $scope.conversation.prompt
					messageId: data.id
					toId: data.to.id
					toName: data.to.name
					fromId: data.from.id
					fromName: data.from.name
			else
				analytics.track 'message conversation save draft',
					href: window.location.href
					routeId: $routeParams.id
					conversationId: $scope.conversation.id
					conversationPrompt: $scope.conversation.prompt
					messageId: data.id
					toId: data.to.id
					toName: data.to.name
					fromId: data.from.id
					fromName: data.from.name
		error = (error) ->
			$scope.app.flash 'error', error.data.errors
			analytics.track 'message conversation error',
				href: window.location.href
				routeId: $routeParams.id
				conversationId: $scope.conversation.id
				conversationPrompt: $scope.conversation.prompt
				error: JSON.stringify(error)

		if state_event? then $scope.myMessage.state_event = state_event

		$scope.myMessage.save success, error

]

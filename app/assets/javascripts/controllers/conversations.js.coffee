root = global ? window

root.conversationsIndexCtrl = ps.controller "ConversationsIndexCtrl", ["$scope", "$location", "$timeout", "Conversation", "conversations", ($scope, $location, $timeout, Conversation, conversations) ->
	$scope.conversations = conversations
	$scope.app.meta.title = "My Conversations"
	$scope.selectedFilter = $location.search().filter or 'ready'
	$scope.busy = true
	$timeout ->
		$scope.busy = false
	, 1500

	$scope.filter = (filter) ->
		$location.search({filter: filter})
		analytics.track "filter conversations",
			filter: filter

	$scope.loadMoreConversations = ->
		if $scope.conversations.query and $scope.conversations.query.page < $scope.conversations.total_pages
			$scope.conversations.query.page += 1
			$scope.busy = true
			$scope.app.show.loading = true
			Conversation.query $scope.conversations.query, (response) ->
				$scope.conversations.collection = $scope.conversations.collection.concat response.collection
				$scope.app.show.loading = false
				$scope.busy = false unless $scope.conversations.query.page >= $scope.conversations.total_pages

]
root.conversationsIndexCtrl.loadConversations = ["$q", "$location", "Conversation", ($q, $location, Conversation) ->
	defered = $q.defer()
	query = {user_id: 'me', per: 5, page: 1}
	filter = $location.search().filter or 'ready'
	switch filter
		when 'all' then _.extend(query, {order: "updated_at DESC"})
		when 'ready' then _.extend(query, {state: 'in_progress', turn_id: 'me', order: "updated_at ASC"})
		when 'waiting' then _.extend(query, {state: 'in_progress', not_turn_id: 'me', order: "updated_at DESC"})
		when 'ended' then _.extend(query, {state: 'ended', order: "updated_at DESC"})
	Conversation.query query, (conversations) ->
		defered.resolve(conversations)
		analytics.track 'view conversations success'
	, (error) ->
		$location.search('path', window.location.pathname)
		$location.search('search', window.location.search)
		$location.path('/login')
		# $scope.app.flash 'info', "Sorry, we don't know whose conversations to show you. Please log in."
		analytics.track 'view conversations error',
			error: 'not logged in'
		# defered.reject(error)
	defered.promise
]


ps.controller "ConversationsShowCtrl", ["$scope", "$routeParams", "$location", "$timeout", "Message", "Conversation", ($scope, $routeParams, $location, $timeout, Message, Conversation) ->
	# $scope.conversations = []
	$scope.conversation = {}
	$scope.message = {}
	$scope.messages = {collection: []}
	$scope.myMessage = {}
	$scope.lastMsg = {}
	$scope.show = {conversation: false, embedInput: false}

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
		$scope.query = {user_id: user.id, conversation_id: $routeParams.id, page: 1}
		$scope.messages = Message.query $scope.query, (messages) ->
			$scope.lastMsg = _.last(messages.collection)
			$scope.message = $scope.lastMsg unless $routeParams.message_id
	, (error) ->
		# user must log in to view a conversation
		$location.search('path', window.location.pathname)
		$location.search('search', window.location.search)
		$location.path('/login')
		$scope.app.flash 'info', "Please log in to view this conversation."
		analytics.track 'view conversation error',
			routeId: $routeParams.id
			error: 'not logged in'


	$scope.$watch 'myMessage.body', (value) ->
		$scope.remainingChars = 250 - (if value? then value.length else 0)


	$scope.$watch 'show.embedInput', (value) ->
		if value
			analytics.track 'click reveal embed url input',
				href: window.location.href
				routeId: $routeParams.id

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
					conversationDuration: (Date.parse(new Date) - Date.parse(new Date($scope.conversation.created_at)))
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
					conversationDuration: (Date.parse(new Date) - Date.parse(new Date($scope.conversation.created_at)))
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
			$scope.app.loading = false
			$scope.app.flash 'success', 'Great, your message has been sent.'
			if data.state == 'sent'
				$scope.messages.collection.push $scope.myMessage
				previousMsg = angular.copy($scope.lastMsg)
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
					hasEmbedUrl: $scope.myMessage.embed_url?
					timeToReply: (Date.parse(new Date) - Date.parse(new Date(previousMsg.created_at)))
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
					hasEmbedUrl: $scope.myMessage.embed_url?
					timeToReply: (Date.parse(new Date) - Date.parse(new Date($scope.lastMsg.created_at)))
		error = (error) ->
			$scope.app.loading = false
			$scope.app.flash 'error', error.data.errors
			analytics.track 'message conversation error',
				href: window.location.href
				routeId: $routeParams.id
				conversationId: $scope.conversation.id
				conversationPrompt: $scope.conversation.prompt
				hasEmbedUrl: $scope.myMessage.embed_url?
				timeToReply: (Date.parse(new Date) - Date.parse(new Date($scope.lastMsg.created_at)))
				error: JSON.stringify(error)

		$scope.app.loading = true
		if state_event? then $scope.myMessage.state_event = state_event
		delete $scope.myMessage['embed_url'] unless $scope.show.embedInput
		$scope.myMessage.save success, error

]

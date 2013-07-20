root = global ? window

ps.controller "ConversationsIndexCtrl", ["$scope", "$location", "$timeout", "Conversation", "conversations", ($scope, $location, $timeout, Conversation, conversations) ->
	$scope.conversations = conversations
	$scope.app.meta.title = "My Conversations"
	$scope.selectedFilter = $location.search().filter or 'all'
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
root.resolves.conversationsIndex =
	conversations: ["$q", "$location", "Conversation", ($q, $location, Conversation) ->
		defered = $q.defer()
		query = {user_id: 'me', per: 10, page: 1}
		filter = $location.search().filter or 'all'
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


ps.controller "ConversationsShowCtrl", ["$scope", "conversation", ($scope, conversation) ->
	$scope.conversation = conversation
	$scope.app.meta.title = "Conversation · #{conversation.from.name} -> #{conversation.to.name}"
]
root.resolves.conversationsShow =
	conversation: ["$q", "$route", "$location", "Conversation", ($q, $route, $location, Conversation) ->
		defered = $q.defer()
		query = {user_id: 'me', id: $route.current.params.id}
		Conversation.get query, (conversation) ->
			defered.resolve(conversation)
			analytics.track 'view conversation success'
		, (error) ->
			$location.search('path', window.location.pathname)
			$location.search('search', window.location.search)
			$location.path('/login')
			# $scope.app.flash 'info', "Please log in first."
			analytics.track 'view conversation error',
				error: 'not logged in'
			# defered.reject(error)
		defered.promise
	]



ps.controller "ConversationsPartialCtrl", ["$scope", "$location", "$timeout", "Conversation", "Message", "User", ($scope, $location, $timeout, Conversation, Message, User) ->
	$scope.conversation = new Conversation $scope.conversation
	$scope.expanded = false
	$scope.messages = { collection: [] }
	$scope.options = {}
	$scope.hideAll = false
	# $scope.animateCss = 'animated bounceOutLeft'
	# $scope.autosave = { body: "reply_to_msg_id_#{$scope.conversation?.last_message_id}" }

	$scope.init = (options = {}) ->
		$scope.options.animateExit = options.animateExit?
		$scope.options.redirectAfterSuccess = options.redirectAfterSuccess?
		$scope.toggleExpand() if options.toggleExpand?

	$scope.toggleExpand = ->
		if $scope.expanded
			$scope.expanded = false
			$scope.messages = { collection: [] }
		else
			$scope.expanded = true
			$scope.myMessage = new Message {user_id: $scope.conversation.partners_id, conversation_id: $scope.conversation.id}
			$scope.show = {embedInput: false}
			if $scope.messages.collection.length == 0
				loadMessages()

	loadMessages = ->
		query = {user_id: 'me', conversation_id: $scope.conversation.id}
		$scope.messages = Message.query query

	$scope.$watch 'show.embedInput', (value) ->
		if value
			analytics.track 'click reveal embed url input',
				href: window.location.href

	$scope.end = ->
		# if window.confirm 'This conversation is finished.'
		$scope.conversation.state_event = 'end'
		$scope.conversation.save (conversation) ->
			$scope.app.currentUser.ready_conversations_count -= 1
			$scope.app.currentUser.ended_conversations_count += 1
			$scope.animateCss = 'animated bounceOutRight' if $scope.options.animateExit?
			$timeout ->
				$scope.hideAll = true
			, 500
			$location.path("/conversations") if $scope.options.redirectAfterSuccess?
			analytics.track 'end conversation success',
				href: window.location.href
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
				conversationId: $scope.conversation.id
				conversationPrompt: $scope.conversation.prompt
				toId: $scope.conversation.to.id
				toName: $scope.conversation.to.name
				fromId: $scope.conversation.from.id
				fromName: $scope.conversation.from.name
				conversationDuration: (Date.parse(new Date) - Date.parse(new Date($scope.conversation.created_at)))
				error: JSON.stringify(error)


	$scope.save = (state_event = null) ->
		success = (data) ->
			$scope.app.loading = false
			$scope.app.flash 'success', 'Great, your message has been sent.'
			if data.state == 'sent'
				$scope.messages.collection.push $scope.myMessage
				$scope.app.currentUser.ready_conversations_count -= 1
				$scope.app.currentUser.waiting_conversations_count += 1
				$scope.conversation = new Conversation data.conversation
				$scope.animateCss = 'animated bounceOutLeft' if $scope.options.animateExit?
				$timeout ->
					$scope.hideAll = true
				, 500
				$location.path("/conversations") if $scope.options.redirectAfterSuccess?
				analytics.track 'message conversation success',
					href: window.location.href
					conversationId: $scope.conversation.id
					conversationPrompt: $scope.conversation.prompt
					messageId: data.id
					toId: data.to.id
					toName: data.to.name
					fromId: data.from.id
					fromName: data.from.name
					hasEmbedUrl: $scope.myMessage.embed_url?
					# timeToReply: (Date.parse(new Date) - Date.parse(new Date(previousMsg.created_at)))
			else
				analytics.track 'message conversation save draft',
					href: window.location.href
					conversationId: $scope.conversation.id
					conversationPrompt: $scope.conversation.prompt
					messageId: data.id
					toId: data.to.id
					toName: data.to.name
					fromId: data.from.id
					fromName: data.from.name
					hasEmbedUrl: $scope.myMessage.embed_url?
					# timeToReply: (Date.parse(new Date) - Date.parse(new Date($scope.lastMsg.created_at)))
		error = (error) ->
			$scope.app.loading = false
			$scope.app.flash 'error', error.data.errors
			analytics.track 'message conversation error',
				href: window.location.href
				conversationId: $scope.conversation.id
				conversationPrompt: $scope.conversation.prompt
				hasEmbedUrl: $scope.myMessage.embed_url?
				# timeToReply: (Date.parse(new Date) - Date.parse(new Date($scope.lastMsg.created_at)))
				error: JSON.stringify(error)

		$scope.app.loading = true
		if state_event? then $scope.myMessage.state_event = state_event
		delete $scope.myMessage['embed_url'] unless $scope.show.embedInput
		$scope.myMessage.save success, error

]

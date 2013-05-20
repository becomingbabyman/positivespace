root = global ? window


# Index
root.usersIndexCtrl = ps.controller "UsersIndexCtrl", ["$scope", "$routeParams", "$timeout", "$location", "User", "users", ($scope, $routeParams, $timeout, $location, User, users) ->
	$scope.users = users
]
root.usersIndexCtrl.loadUsers = ["$q", "User", ($q, User) ->
	defered = $q.defer()
	User.query { order: 'updated_at DESC' }, (users) ->
		defered.resolve(users)
	, (error) ->
		defered.reject(error)
	defered.promise
]


# Login
ps.controller "UsersLoginCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
	$scope.app.meta.title = "Log in · Positive Space"
]


# Register
ps.controller "UsersRegisterCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
	$scope.app.meta.title = "Start · Positive Space"
]


# Reset Password
ps.controller "UserPasswordEditCtrl", ["$scope", "$location", "$routeParams", "User", ($scope, $location, $routeParams, User) ->
	$scope.app.show.noChrome()
	$scope.app.meta.title = "Reset Password · Positive Space"

	$scope.psw = {password: '', passwordConfirmation: ''}

	$scope.updatePassword = ->
		User.updatePassword
			user:
				password: $scope.psw.password
				password_confirmation: ($scope.psw.passwordConfirmation or '')
				reset_password_token: $routeParams.reset_password_token
			(data) ->
				$scope.app.flash 'success', "Cool, your password has been updated and you are now logged in."
				$scope.app.loadCurrentUser data
				$location.path("/#{data.username}")
				analytics.track 'reset password success'
			(error) ->
				$scope.app.flash 'error', error.data.errors
				analytics.track 'reset password error',
					error: JSON.stringify(error)
]


# Edit
ps.controller "UsersEditCtrl", ["$scope", "$routeParams", "$timeout", "$location", "User", ($scope, $routeParams, $timeout, $location, User) ->
	$scope.space = {}
	$scope.user = User.get {id: $routeParams.user_id}, ->
		# Can the user view the form
		$scope.app.dcu.promise.then (currentUser) ->
			if $scope.user.id != currentUser.id
				$location.path("/#{$scope.user.slug}")
		, (error) ->
			$location.path("/#{$scope.user.slug}")

		# Can the user close the edit form?
		if !$scope.user.body? or $scope.user.body.length == 0
			$scope.space.cantCloseEdit = true
		$scope.app.meta.title = "Edit #{$scope.user.name}"
		$scope.app.meta.description = "Configure your space just the way you want it."
		$scope.app.meta.imageUrl = $scope.user.avatar.big_thumb_url
		analytics.track 'view edit space success',
			href: window.location.href
			routeId: $routeParams.user_id
			userId: $scope.user.id
			userName: $scope.user.name
			userBody: $scope.user.body
	, (error) ->
		$location.path('/404')
		analytics.track 'view edit space error',
			routeId: $routeParams.user_id

	$scope.$watch 'user.body', (value) ->
		$scope.userBodyRemaining = 250 - (if value? then value.length else 0)

	# TODO: revert to original profile if close is clicked instead of save
	$scope.saveSpace = ->
		if $scope.user.body? and $scope.user.body.length > 0
			$scope.app.show.loading = true
			success = (data) ->
				$scope.app.show.loading = false
				$scope.app.flash 'success', 'Great, your space has been updated.'
				analytics.track 'save space success',
					href: window.location.href
					routeId: $routeParams.user_id
					userId: $scope.user.id
					userName: $scope.user.name
					userBody: $scope.user.body
					firstSave: $scope.space.cantCloseEdit
				$location.path("/#{$scope.user.slug}")
			error = (error) ->
				$scope.app.show.loading = false
				$scope.app.flash 'error', error.data.errors
				analytics.track 'save space error',
					href: window.location.href
					routeId: $routeParams.user_id
					userId: $scope.user.id
					userName: $scope.user.name
					userBody: $scope.user.body
					firstSave: $scope.space.cantCloseEdit
					error: JSON.stringify(error)
			$scope.user.save success, error
		else
			angular.element('textarea#user_body').focus()
			$scope.app.flash 'info', "Please share what you want to talk about. Then you can see your space."

]


# Show
root.usersShowCtrl = ps.controller "UsersShowCtrl", ["$scope", "$routeParams", "$timeout", "$location", "User", "Message", "Conversation", "user", ($scope, $routeParams, $timeout, $location, User, Message, Conversation, user) ->
	$scope.user = user

	$scope.space = {fadeCount: 0}
	$scope.show = {embedInput: false, form: false}
	$scope.chart = { views: { values: {} } }

	$scope.app.meta.title = "#{$scope.user.name}"
	$scope.app.meta.description = "#{$scope.user.body}"
	$scope.app.meta.imageUrl = $scope.user.avatar.big_thumb_url

	if !$scope.user.body? or $scope.user.body.length == 0
		$scope.app.dcu.promise.then (currentUser) ->
			if $scope.user.id == currentUser.id
				$location.path("/#{currentUser.slug}/edit")
				analytics.track 'view space error',
					routeId: $routeParams.user_id
					type: 'redirect to edit'

	$scope.app.dcu.promise.then (currentUser) ->
		if $scope.user.id == currentUser.id
			User.metrics {metrics: "views,responses,initiations"}, (metrics) ->
				$scope.chart.views.values.x = [0..metrics.views.length-1]
				$scope.chart.views.values.y = [metrics.views, metrics.initiations, metrics.responses]
				$scope.chart.views.values.labels = ['views', 'initiations', 'responses']
				$scope.chart.views.opts = {}
			User.metrics {metrics: "responses,initiations", days_range:10000, intervals: 1}, (metrics) ->
				$scope.totalResponses = metrics.responses[0]
				$scope.totalInitiations = metrics.initiations[0]
		else
			# Check for in_progress conversation
			Conversation.query {user_id: currentUser.id, to: $scope.user.id, state: 'in_progress', order: 'created_at DESC'}, (conversations) ->
				$scope.conversation = conversations.collection[0]

	$scope.message = new Message {user_id: $routeParams.user_id}

	$scope.$watch 'message.body', (value) ->
		# Update the count
		$scope.remainingChars = 250 - (if value? then value.length else 0)
		# Fade distractions out while typing
		if $scope.remainingChars < 250
			if $scope.space.fadeCount == 3 then $('#msg_remaining_chars').fadeOut()
			$scope.space.fadeCount += 1
			$timeout ->
				$scope.space.fadeCount -= 1
				if $scope.space.fadeCount == 0 then $('#msg_remaining_chars').fadeIn()
			, 1400

	$scope.$watch 'show.embedInput', (value) ->
		if value
			analytics.track 'click reveal embed url input',
				href: window.location.href
				routeId: $routeParams.id

	$scope.respond = ->
		unless $scope.show.form
			$scope.show.form = true
			analytics.track 'click respond',
				href: window.location.href
				routeId: $routeParams.user_id
				userId: $scope.user.id
				userName: $scope.user.name
				userBody: $scope.user.body
				currentId: $scope.app.currentUser.id
				currentName: $scope.app.currentUser.name

	$scope.requestEmbedCode = ->
		analytics.track 'request embed code'
		window.alert "This feature is under development. In the meantime you can link you your space \"#{window.location.href}\" from your website or blog. And you can speak with us at \"people@positivespace.io\" and share your thoughts about embedding. We are sorry for the inconvenience."


	$scope.submitMessage = ->
		if $scope.app.loggedIn()
			$scope.app.show.loading = true
			success = (data) ->
				$scope.app.show.loading = false
				$scope.app.flash 'success', 'Great, your message has been sent.'
				analytics.track 'message space success',
					href: window.location.href
					routeId: $routeParams.user_id
					userId: $scope.user.id
					userName: $scope.user.name
					userBody: $scope.user.body
					fromId: $scope.app.currentUser.id
					fromName: $scope.app.currentUser.name
					hasEmbedUrl: $scope.message.embed_url?
			error = (error) ->
				$scope.app.show.loading = false
				$scope.app.flash 'error', error.data.errors
				analytics.track 'message space error',
					href: window.location.href
					routeId: $routeParams.user_id
					userId: $scope.user.id
					userName: $scope.user.name
					userBody: $scope.user.body
					fromId: $scope.app.currentUser.id
					fromName: $scope.app.currentUser.name
					hasEmbedUrl: $scope.message.embed_url?
					error: JSON.stringify(error)
			$scope.message.state_event = 'send'
			delete $scope.message['embed_url'] unless $scope.show.embedInput
			$scope.message.save success, error
		else
			$scope.app.flash 'info', 'It looks like something is missing. Please fill in all fields.'
			analytics.track 'message space error',
				href: window.location.href
				routeId: $routeParams.user_id
				userId: $scope.user.id
				userName: $scope.user.name
				userBody: $scope.user.body
				error: 'not logged in'
]
root.usersShowCtrl.loadUser = ["$q", "$route", "User", ($q, $route, User) ->
	defered = $q.defer()
	User.get { id: $route.current.params.user_id }, (user) ->
		defered.resolve(user)
		analytics.track 'view space success',
			href: window.location.href
			routeId: $route.current.params.user_id
			userId: user.id
			userName: user.name
			userBody: user.body
	, (error) ->
		defered.reject(error)
		analytics.track 'view space error',
			routeId: $route.current.params.user_id
			type: 'not found'
	defered.promise
]


# Settings
ps.controller "UsersSettingsCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.meta.title = "Settings"

	$scope.saveSettings = ->
		$scope.app.show.loading = true
		success = (data) ->
			$scope.app.show.loading = false
			$scope.app.flash 'success', 'Your settings have been saved'
			analytics.track 'save settings success',
				href: window.location.href
				userId: $scope.app.currentUser.id
				userName: $scope.app.currentUser.name
		error = (error) ->
			$scope.app.show.loading = false
			$scope.app.flash 'error', error.data.errors
			analytics.track 'save settings error',
				href: window.location.href
				userId: $scope.app.currentUser.id
				userName: $scope.app.currentUser.name
				error: JSON.stringify(error)
		$scope.app.currentUser.save success, error
]




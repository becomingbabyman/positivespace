ps.controller "UsersLoginCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
	$scope.app.meta.title = "Log in · Positive Space"
]


ps.controller "UsersRegisterCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
	$scope.app.meta.title = "Start · Positive Space"
]


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


ps.controller "UsersShowCtrl", ["$scope", "$routeParams", "$timeout", "$location", "User", "Message", "Conversation", ($scope, $routeParams, $timeout, $location, User, Message, Conversation) ->
	user_id = $routeParams.user_id or 'space'
	$scope.space = {fadeCount: 0}
	$scope.show = {embedInput: false, form: false}
	$scope.chart = { views: { values: {} } }

	$scope.user = User.get {id: user_id}, ->
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

		analytics.track 'view space success',
			href: window.location.href
			routeId: $routeParams.user_id
			userId: $scope.user.id
			userName: $scope.user.name
			userBody: $scope.user.body
	, (error) ->
		$location.path('/404')
		analytics.track 'view space error',
			routeId: $routeParams.user_id
			type: 'not found'


	$scope.message = new Message {user_id: user_id}

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

	$scope.endorse = ->
		if window.confirm("\nPlease note. This action cannot be undone. \n\nEndorsing this space will make it discoverable to the Positive Space community! And this space will forever link to yours. Do you want to endorse #{$scope.user.name}?")
			if $scope.app.loggedIn()
				$scope.user.state = 'endorsed'
				$scope.user.invitation = {user: $scope.app.currentUser}
				User.update
					id: $scope.app.currentUser.id
					endorse_user: $scope.user.id
				, (user) ->
					$scope.app.flash 'success', "Awesome, #{$scope.user.name} is now officially part of the Positive Space community. #{$scope.user.first_name} will be notified and #{window.possessive($scope.user.first_name)} space is now linked to your space."
					analytics.track "endorse space success",
						href: window.location.href
						routeId: $routeParams.user_id
						userId: $scope.user.id
						userName: $scope.user.name
						userBody: $scope.user.body
						currentId: $scope.app.currentUser.id
						currentName: $scope.app.currentUser.name
				, (error) ->
					$scope.user.state = 'unendorsed'
					$scope.user.invitation = null
					$scope.app.flash 'error', error.data.errors
					analytics.track "endorse space error",
						href: window.location.href
						routeId: $routeParams.user_id
						userId: $scope.user.id
						userName: $scope.user.name
						userBody: $scope.user.body
						currentId: $scope.app.currentUser.id
						currentName: $scope.app.currentUser.name
						error: JSON.stringify(error)
			else
				$scope.app.flash 'info', "Log in to endorse #{window.possessive($scope.user.first_name)} space"
				$location.search('path', "/#{$scope.user.slug}")
				$location.path('/login')

	$scope.social = (action) ->
		has = "has_#{action.replace(/^un/, '')}"
		if $scope.app.loggedIn()
			unless $scope.user.id == $scope.app.currentUser.id
				$scope.user[has] = !$scope.user[has]
				User.update
					id: $scope.app.currentUser.id
					socialable_type: 'User'
					socialable_id: $scope.user.id
					socialable_action: action
				, (user) ->
					analytics.track "#{action} space success",
						href: window.location.href
						routeId: $routeParams.user_id
						userId: $scope.user.id
						userName: $scope.user.name
						userBody: $scope.user.body
						currentId: $scope.app.currentUser.id
						currentName: $scope.app.currentUser.name
				, (error) ->
					$scope.user[has] = !$scope.user[has]
					$scope.app.flash 'error', error.data.errors
					analytics.track "#{action} space error",
						href: window.location.href
						routeId: $routeParams.user_id
						userId: $scope.user.id
						userName: $scope.user.name
						userBody: $scope.user.body
						currentId: $scope.app.currentUser.id
						currentName: $scope.app.currentUser.name
						error: JSON.stringify(error)
			else
				$scope.app.flash 'notice', "Sorry, you cannot #{action} yourself"
		else
			$scope.app.flash 'info', "Log in to #{action} #{window.possessive($scope.user.first_name)} space"
			$location.search('path', "/#{$scope.user.slug}")
			$location.path('/login')


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




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


ps.controller "UsersShowCtrl", ["$scope", "$routeParams", "$timeout", "$location", "User", "Message", ($scope, $routeParams, $timeout, $location, User, Message) ->
	user_id = $routeParams.user_id or 'space'
	$scope.space = {fadeCount: 0}
	$scope.show = {embedInput: false}

	$scope.user = User.get {id: user_id}, ->
		$scope.userCopy = angular.copy $scope.user
		if !$scope.user.body? or $scope.user.body.length == 0
			$scope.app.dcu.promise.then (currentUser) ->
				if $scope.user.id == currentUser.id
					$scope.space.editing = true
					$scope.space.cantCloseEdit = true
				else
					$location.path('/')
		$scope.app.meta.title = "#{$scope.user.name}"
		$scope.app.meta.description = "#{$scope.user.body}"
		$scope.app.meta.imageUrl = "<%= asset_path('#{$scope.user.avatar.big_thumb_url}') %>"
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


	$scope.message = new Message {user_id: user_id}

	$scope.$watch 'userCopy.body', (value) ->
		$scope.userBodyRemaining = 250 - (if value? then value.length else 0)

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

	# TODO: revert to original profile if close is clicked instead of save
	$scope.saveSpace = ->
		if $scope.userCopy.body? and $scope.userCopy.body.length > 0
			$scope.app.show.loading = true
			success = (data) ->
				$scope.app.show.loading = false
				$scope.space.editing = false
				firstSave = $scope.space.cantCloseEdit
				$scope.space.cantCloseEdit = false
				$scope.user = angular.copy $scope.userCopy
				$scope.app.flash 'success', 'Great, your space has been updated.'
				analytics.track 'save space success',
					href: window.location.href
					routeId: $routeParams.user_id
					userId: $scope.user.id
					userName: $scope.user.name
					userBody: $scope.user.body
					firstSave: firstSave
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

			$scope.userCopy.save success, error
		else
			angular.element('textarea#user_body').focus()
			$scope.app.flash 'info', "Please introduce yourself. And share what you would like to talk about."

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
]




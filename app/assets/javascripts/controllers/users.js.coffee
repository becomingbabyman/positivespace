ps.controller "UsersLoginCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
]


ps.controller "UsersRegisterCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
]


ps.controller "UserPasswordEditCtrl", ["$scope", "$location", "$routeParams", "User", ($scope, $location, $routeParams, User) ->
	$scope.app.show.noChrome()

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
			(error) ->
				$scope.app.flash 'error', error.data.errors
]


ps.controller "UsersShowCtrl", ["$scope", "$routeParams", "$timeout", "$location", "User", "Message", ($scope, $routeParams, $timeout, $location, User, Message) ->
	user_id = $routeParams.user_id or 'space'
	$scope.space = {fadeCount: 0}

	# TODO:
	# $scope.$watch 'app.currentUser.id', ->
	$scope.user = User.get {id: user_id}, ->
		if !$scope.user.body? or $scope.user.body.length == 0
			if $scope.user.id == $scope.app.currentUser.id
				$scope.space.editing = true
				$scope.space.cantCloseEdit = true
			else
				$location.path('/')
	, (error) ->
		$location.path('/404')

	$scope.message = new Message {user_id: user_id}

	$scope.$watch 'user.body', (value) ->
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
		if $scope.user.body? and $scope.user.body.length > 0
			$scope.app.show.loading = true
			success = (data) ->
				$scope.app.show.loading = false
				$scope.space.editing = false
				$scope.space.cantCloseEdit = false
				$scope.app.flash 'success', 'Great, your space has been updated.'
			error = (error) ->
				$scope.app.show.loading = false
				$scope.app.flash 'error', error.data.errors
			$scope.user.save success, error
		else
			angular.element('textarea#user_body').focus()
			$scope.app.flash 'info', "Please introduce yourself. And share what you would like to talk about."

	$scope.submitMessage = ->
		if $scope.app.loggedIn()
			$scope.app.show.loading = true
			success = (data) ->
				$scope.app.show.loading = false
				$scope.app.flash 'success', 'Great, your message has been sent.'
			error = (error) ->
				$scope.app.show.loading = false
				$scope.app.flash 'error', error.data.errors
			$scope.message.state_event = 'send'
			$scope.message.save success, error
		else
			$scope.app.flash 'info', 'It looks like something is missing. Please fill in all fields.'
]


ps.controller "UsersSettingsCtrl", ["$scope", "User", ($scope, User) ->
]




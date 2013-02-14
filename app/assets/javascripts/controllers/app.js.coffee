ps.controller "AppCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app = {}
	$scope.app.currentUser = {}
	$scope.app.preLogin = {rememberMe: true}
	$scope.app.templates =
		header:
			url: "/assets/app/header.html"
			classes: "navbar"
		flash:
			url: "/assets/app/flash.html"
		footer:
			url: "/assets/app/footer.html"
	$scope.app.alerts = []

	# TODO: bootstrap this data on the angular.html.haml template and only request it if no bootstrap is found
	$scope.app.currentUser = User.current()


	$scope.app.flash = (type, msg) ->
		$scope.app.alerts.push {type: type, msg: msg}
	$scope.app.closeAlert = (index) ->
		$scope.app.alerts.splice(index, 1)

	$scope.app.register = (email = $scope.app.preLogin.email, username = $scope.app.preLogin.username, password = $scope.app.preLogin.password, rememberMe = $scope.app.preLogin.rememberMe) ->
		# TODO: display success notification
		# TODO: display error notifications
		User.register
			user:
				email: email
				username: username
				password: password
				remember_me: rememberMe
			(data) ->
				$scope.app.currentUser = data
				$scope.app.preLogin = {}
				$scope.app.flash 'success', "welcome to the community"
			(data) ->
				$scope.app.flash 'error', data.error

	$scope.app.login = (login = $scope.app.preLogin.login, password = $scope.app.preLogin.password, rememberMe = $scope.app.preLogin.rememberMe) ->
		# TODO: display success notification
		# TODO: display error notifications
		User.login
			user:
				login: login
				password: password
				remember_me: rememberMe
			(data) ->
				$scope.app.currentUser = data
				$scope.app.preLogin = {}
				$scope.app.flash 'success', "nice, you're in!"
			(data) ->
				$scope.app.flash 'error', "oops, that's the wrong username or password"

	$scope.app.logout = ->
		# TODO: display success notification
		# TODO: display error notifications
		$scope.app.currentUser = User.logout()
		$scope.app.flash 'success', "bye, hope to see you again soon"

	$scope.app.resetPassword = (login = $scope.app.preLogin.login) ->
		# TODO: display success notification
		# TODO: display error notifications
		# TODO: handle the reset password link page in angular
		User.resetPassword
			user:
				login: login
			(data) ->
				$scope.app.preLogin = {}
				$scope.app.flash 'success', "check your inbox (and spam folder) for reset password instructions. it should arrive in less than a minute." 
			(data) ->
				$scope.app.flash 'error', data.error


]


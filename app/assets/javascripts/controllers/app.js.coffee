ps.controller "AppCtrl", ["$scope", "$http", "User", ($scope, $http, User) ->
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
	$scope.app.currentUser = User.current()


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

	$scope.app.logout = ->
		# TODO: display success notification
		# TODO: display error notifications
		$scope.app.currentUser = User.logout()

	$scope.app.resetPassword = (login = $scope.app.preLogin.login) ->
		# TODO: display success notification
		# TODO: display error notifications
		# TODO: handle the reset password link page in angular
		User.resetPassword
			user:
				login: login
			(data) ->
				$scope.app.preLogin = {}
]
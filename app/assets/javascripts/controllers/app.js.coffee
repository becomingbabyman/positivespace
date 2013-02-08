ps.controller "AppCtrl", ["$scope", "$http", "User", ($scope, $http, User) ->
	$scope.app = {}
	$scope.app.templates =
		header:
			url: "/assets/app/header.html"
			classes: "navbar"
		flash:
			url: "/assets/app/flash.html"
		footer:
			url: "/assets/app/footer.html"
	$scope.app.currentUser = User.current()

	$scope.app.login = (login, password, remember_me = 0) ->
		$scope.app.currentUser = User.login
			user:
				login: login
				password: password
				remember_me: remember_me

	$scope.app.logout = ->
		User.logout()
		$scope.app.currentUser = {}
]
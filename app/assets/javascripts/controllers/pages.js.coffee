root = global ? window


ps.controller "PagesCtrl", ["$scope", ($scope) ->

]

ps.controller "PagesHomeCtrl", ["$scope", "$location", ($scope, $location) ->

]
root.resolves.pagesHome =
	user: ["$q", "$route", "$location", "User", ($q, $route, $location, User) ->
		defered = $q.defer()
		User.current (user) ->
			# defered.resolve(user)
			$location.path("/#{user.slug}")
		, (error) ->
			# defered.resolve(false)
			window.location.href = "/"
		defered.promise
	]

ps.controller "PagesRandomCtrl", ["$scope", ($scope) ->
	_.defer ->
		$scope.app.randomSpace()
]

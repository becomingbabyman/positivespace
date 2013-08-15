root = global ? window


ps.controller "PagesCtrl", ["$scope", ($scope) ->

]

ps.controller "PagesHomeCtrl", ["$scope", "$location", ($scope, $location) ->
	$scope.app.show.loading = true
	$scope.app.loadCurrentUser().then (user) ->
		$scope.app.show.loading = false
		if user.slug?.length > 0 then $location.path("/#{user.slug}") else $location.path("/random")
	, (error) ->
		window.location.href = "/"
]

ps.controller "PagesPreviousUrlCtrl", ["$scope", "$location", ($scope, $location) ->
	window.location.href = amplify.store('previousUrl') or "/"
]

ps.controller "PagesRandomCtrl", ["$scope", ($scope) ->
	_.defer ->
		$scope.app.randomSpace()
]

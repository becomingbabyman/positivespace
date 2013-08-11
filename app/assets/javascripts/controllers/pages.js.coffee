ps.controller "PagesCtrl", ["$scope", ($scope) ->

]

ps.controller "PagesHomeCtrl", ["$scope", ($scope) ->
	window.location.href = '/'
]

ps.controller "PagesRandomCtrl", ["$scope", ($scope) ->
	_.defer ->
		$scope.app.randomSpace()
]

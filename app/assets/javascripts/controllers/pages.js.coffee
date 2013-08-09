ps.controller "PagesCtrl", ["$scope", ($scope) ->

]

ps.controller "PagesRandomCtrl", ["$scope", ($scope) ->
	_.defer ->
		$scope.app.randomSpace()
]

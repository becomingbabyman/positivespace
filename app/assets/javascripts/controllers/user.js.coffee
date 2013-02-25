ps.controller "UsersCtrl", ["$scope", "$location", "$routeParams", "User", ($scope, $location, $routeParams, User) ->
	$scope.user = {}

	# Remove the header and footer from the login and register pages
	if $location.path() == '/login' or $location.path() == '/register'
		$scope.app.show.noChrome()

	# Get the user from the params
	if (id = $routeParams.userId) and id?
		$scope.user = User.get({id: id})
]

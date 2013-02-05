ps.controller "AppCtrl", ["$scope", "$http", ($scope, $http) ->
	$scope.app = {}
	$scope.app.templates =
		header:
			url: "assets/app/header.html"
			classes: "navbar"
		flash:
			url: "assets/app/flash.html"
		footer:
			url: "assets/app/footer.html"	
	# $scope.app.user = $http("/users/current")
]
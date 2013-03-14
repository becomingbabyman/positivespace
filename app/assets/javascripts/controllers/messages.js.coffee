ps.controller "MessagesInboxCtrl", ["$scope", "$location", "$timeout", "Message", ($scope, $location, $timeout, Message) ->
	$scope.$watch 'app.currentUser.id', (id) ->
		if id?
			$scope.messages = Message.query({user_id: id})
		else
			# user must log in to view inbox
			$location.path('/login')

	$scope.endConvo = ->
		el = angular.element('.message').first()
		el.addClass 'animated bounceOutLeft'
		$timeout ->
			$scope.messages = $scope.messages.splice 1
		, 500

	$scope.continueConvo = ->
		el = angular.element('.message').first()
		el.addClass 'animated bounceOutRight'
		$timeout ->
			$scope.messages = $scope.messages.splice 1
		, 500
]


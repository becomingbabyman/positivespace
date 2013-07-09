root = global ? window


# Index
root.usersIndexCtrl = ps.controller "UsersIndexCtrl", ["$scope", "$routeParams", "$timeout", "$location", "User", "users", ($scope, $routeParams, $timeout, $location, User, users) ->
	$scope.users = users
	$scope.filter = 'recent'
	$scope.busy = true
	$timeout ->
		$scope.busy = false
	, 1500

	$scope.updateFilter = ->
		$scope.app.show.loading = true
		switch $scope.filter
			when 'recent'
				query = { order: 'updated_at DESC', per: 5 }
			when 'following'
				query = { following: $scope.app.currentUser.id, per: 5 }
			when 'followers'
				query = { followers: $scope.app.currentUser.id, per: 5 }
		$scope.users = User.query query, ->
			$scope.app.show.loading = false
		, ->
			$scope.app.show.loading = false
		analytics.track 'filter users',
			filter: $scope.filter

	$scope.loadMoreUsers = ->
		if $scope.users.query.page < $scope.users.total_pages
			$scope.users.query.page += 1
			$scope.busy = true
			$scope.app.show.loading = true
			User.query $scope.users.query, (response) ->
				$scope.users.collection = $scope.users.collection.concat response.collection
				$scope.app.show.loading = false
				$scope.busy = false unless $scope.users.query.page >= $scope.users.total_pages


]
root.usersIndexCtrl.loadUsers = ["$q", "User", ($q, User) ->
	defered = $q.defer()
	User.query { order: 'updated_at DESC', per: 5 }, (users) ->
		defered.resolve(users)
	, (error) ->
		defered.reject(error)
	defered.promise
]


# Login
ps.controller "UsersLoginCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
	$scope.app.meta.title = "Log in · Positive Space"
]


# Register
ps.controller "UsersRegisterCtrl", ["$scope", "User", ($scope, User) ->
	$scope.app.show.noChrome()
	$scope.app.meta.title = "Start · Positive Space"
]


# Reset Password
ps.controller "UserPasswordEditCtrl", ["$scope", "$location", "$routeParams", "User", ($scope, $location, $routeParams, User) ->
	$scope.app.show.noChrome()
	$scope.app.meta.title = "Reset Password · Positive Space"

	$scope.psw = {password: '', passwordConfirmation: ''}

	$scope.updatePassword = ->
		User.updatePassword
			user:
				password: $scope.psw.password
				password_confirmation: ($scope.psw.passwordConfirmation or '')
				reset_password_token: $routeParams.reset_password_token
			(data) ->
				$scope.app.flash 'success', "Cool, your password has been updated and you are now logged in."
				$scope.app.loadCurrentUser data
				$location.path("/#{data.username}")
				analytics.track 'reset password success'
			(error) ->
				$scope.app.flash 'error', error.data.errors
				analytics.track 'reset password error',
					error: JSON.stringify(error)
]


# Edit
root.usersEditCtrl = ps.controller "UsersEditCtrl", ["$scope", "$routeParams", "$timeout", "$location", "User", "user", ($scope, $routeParams, $timeout, $location, User, user) ->
	$scope.user = user
	$scope.inputs = {}
	inspirationalPeople = [
		"Mahatma Gandhi"
		"Mother Teresa"
		"Martin Luther King"
		"Albert Einstein"
		"Leonardo da Vinci"
		"Helen Keller"
		"Muhammad Ali"
		"John Doe"
		"Jane Doe"
		"Florence Nightingale"
		"Anne Frank"
		"Socrates"
		"William Shakespeare"
		"Eleanor Roosevelt"
		"Rabindranath Tagore"
		"Tenzin Gyatso"
	]
	$scope.inputs.namePlaceholder = inspirationalPeople[Math.floor(Math.random() * inspirationalPeople.length)]
	$scope.inputs.maxTagSize = 5

	# Can the user view the form
	$scope.app.dcu.promise.then (currentUser) ->
		if $scope.user.id != currentUser.id
			$location.path("/#{$scope.user.slug}")
	, (error) ->
		$scope.app.flash('info', 'Log in to edit your profile')
		$location.search('path', window.location.pathname)
		$location.search('search', window.location.search)
		$location.path('/login')
		analytics.track 'view edit space error',
			routeId: $routeParams.user_id

	# Can the user close the edit form?
	if !$scope.user.space.prompt? or $scope.user.space.prompt.length == 0
		$scope.inputs.cantCloseEdit = true

	$scope.app.meta.title = "Edit #{$scope.user.name}"
	$scope.app.meta.description = "Configure your space just the way you want it."
	$scope.app.meta.imageUrl = $scope.user.avatar.big_thumb_url
	$scope.originalUsername = angular.copy $scope.user.username
	if parseInt($scope.originalUsername) == $scope.user.id then $scope.user.username = null
	if $scope.user.username == $scope.user.name then $scope.user.name = null

	select2Options = (tagSet) ->
		tags: true
		# minimumInputLength: 3
		maximumInputLength: 30
		maximumSelectionSize: $scope.inputs.maxTagSize
		tokenSeparators: [","]
		createSearchChoice: (term, data) ->
			if ($(data).filter((() -> this.text.localeCompare(term) == 0)).length == 0) then {id:term, text:term}
		ajax:
			url: '/api/tags'
			data: (term, page) -> # page is the one-based page number tracked by Select2
				{
					q: term #search term
					per: 10 # page size
					page: page # page number
				}
			results: (data, page) ->
				more = (page * 10) < data.total # whether or not there are more results available
				# notice we return the value of more so Select2 knows if more results can be loaded
				return {results: _.map(data.collection, ((t) -> {id: t.name, text: t.name})), more: more}
				# return {results: _.pluck(data.collection, 'name'), more: more}
		initSelection: (element, callback) ->
			callback(_.map(user[tagSet], ((t) -> {id: t, text: t})))
	$scope.skillsOptions = select2Options('skills')
	$scope.interestsOptions = select2Options('interests')


	$scope.usernameIsUnset = ->
		if $scope.user then parseInt($scope.originalUsername) == $scope.user.id else false

	$scope.addTag = (tagSet, tag) ->
		if $scope.user[tagSet].length < $scope.inputs.maxTagSize
			$scope.user[tagSet] = $scope.user[tagSet].concat([{id: tag, text: tag}])
		else
			$scope.app.flash 'info', "Sorry, max #{$scope.inputs.maxTagSize} #{tagSet}"

	# TODO: revert to original profile if close is clicked instead of save
	$scope.saveSpace = ->
		if $scope.user.prompt? and $scope.user.prompt.length > 0 and $scope.user.bio? and $scope.user.bio.length > 0
			$scope.app.show.loading = true
			$scope.userCopy = angular.copy $scope.user
			$scope.userCopy.skills = _.pluck($scope.user.skills, 'text').join(",")
			$scope.userCopy.interests = _.pluck($scope.user.interests, 'text').join(",")
			success = (data) ->
				$scope.app.show.loading = false
				$scope.app.flash 'success', 'Great, your space has been updated.'
				analytics.track 'save space success',
					href: window.location.href
					routeId: $routeParams.user_id
					userId: $scope.userCopy.id
					userName: $scope.userCopy.name
					firstSave: $scope.inputs.cantCloseEdit
					namePlaceholder: $scope.inputs.namePlaceholder
				$scope.app.loadCurrentUser()
				$location.path("/#{$scope.userCopy.slug}")
			error = (error) ->
				$scope.app.show.loading = false
				$scope.app.flash 'error', error.data.errors
				analytics.track 'save space error',
					href: window.location.href
					routeId: $routeParams.user_id
					userId: $scope.userCopy.id
					userName: $scope.userCopy.name
					firstSave: $scope.inputs.cantCloseEdit
					namePlaceholder: $scope.inputs.namePlaceholder
					error: JSON.stringify(error)
			$scope.userCopy.save success, error
		else
			unless $scope.user.bio? and $scope.user.bio.length > 0
				angular.element('textarea#user_bio').focus()
			else
				angular.element('textarea#user_space_prompt').focus()
			$scope.app.flash 'info', "Make sure you fill in your Bio and your Prompt."

]
root.usersEditCtrl.loadEditUser = ["$q", "$route", "$location", "User", ($q, $route, $location, User) ->
	defered = $q.defer()
	User.get { id: $route.current.params.user_id }, (user) ->
		defered.resolve(user)
		analytics.track 'view edit space success',
			href: window.location.href
			routeId: $route.current.params.user_id
			userId: user.id
			userName: user.name
			userPrompt: user.space?.prompt
	, (error) ->
		# $scope.app.flash('info', 'Log in to edit your profile')
		$location.search('path', window.location.pathname)
		$location.search('search', window.location.search)
		$location.path('/login')
		analytics.track 'view edit space error',
			routeId: $route.current.params.user_id
	defered.promise
]



# Show
root.usersShowCtrl = ps.controller "UsersShowCtrl", ["$scope", "$routeParams", "$timeout", "$location", "$q", "User", "Message", "Conversation", "user", ($scope, $routeParams, $timeout, $location, $q, User, Message, Conversation, user) ->
	$scope.user = user

	$scope.space = {fadeCount: 0}
	$scope.show = {embedInput: false, form: false}
	$scope.chart = { values: $q.defer() }

	$scope.app.meta.title = "#{$scope.user.name}"
	$scope.app.meta.description = "#{$scope.user.bio} - #{$scope.user.space?.prompt}"
	$scope.app.meta.imageUrl = $scope.user.avatar.big_thumb_url

	$scope.show.form = if $routeParams['respond'] == 'true' then true else false

	if !$scope.user.space?.prompt? or $scope.user.space?.prompt?.length == 0
		$scope.app.dcu.promise.then (currentUser) ->
			if $scope.user.id == currentUser.id
				$location.path("/#{currentUser.slug}/edit")
				analytics.track 'view space error',
					routeId: $routeParams.user_id
					type: 'redirect to edit'

	$scope.app.dcu.promise.then (currentUser) ->
		if $scope.user.id == currentUser.id
			# TODO: figure out why the raphael graph is 1/4 the width when showAdmin is false and it starts off hidden. It probably has something to do with the width of a hidden div
			$scope.showAdmin = if $scope.user.sign_in_count == 3 then true else false
			User.metrics {metrics: "views,responses,initiations"}, (metrics) ->
				values = {}
				values.x = [0..metrics.views.length-1]
				values.y = [metrics.views, metrics.initiations, metrics.responses]
				values.labels = ['views', 'initiations', 'responses']
				values.opts = {smooth: true}
				$scope.chart.values.resolve values
			User.metrics {metrics: "responses,initiations", days_range:10000, intervals: 1}, (metrics) ->
				$scope.totalResponses = metrics.responses[0]
				$scope.totalInitiations = metrics.initiations[0]
		else
			# Check for in_progress conversation
			Conversation.query {user_id: currentUser.id, to: $scope.user.id, state: 'in_progress', order: 'created_at DESC'}, (conversations) ->
				$scope.conversation = conversations.collection[0]

	$scope.$watch 'show.embedInput', (value) ->
		if value
			analytics.track 'click reveal embed url input',
				href: window.location.href
				routeId: $routeParams.id

	$scope.requestEmbedCode = ->
		analytics.track 'request embed code'
		window.alert "This feature is under development. In the meantime you can link you your space \"#{window.location.href}\" from your website or blog. And you can speak with us at \"people@positivespace.io\" and share your thoughts about embedding. We are sorry for the inconvenience."

]
root.usersShowCtrl.loadUser = ["$q", "$route", "User", ($q, $route, User) ->
	defered = $q.defer()
	User.get { id: $route.current.params.user_id }, (user) ->
		defered.resolve(user)
		analytics.track 'view space success',
			href: window.location.href
			routeId: $route.current.params.user_id
			userId: user.id
			userName: user.name
			userPrompt: user.space?.prompt
	, (error) ->
		defered.reject(error)
		analytics.track 'view space error',
			routeId: $route.current.params.user_id
			type: 'not found'
	defered.promise
]


# Settings
ps.controller "UsersSettingsCtrl", ["$scope", "$location", "User", ($scope, $location, User) ->
	$scope.app.meta.title = "Settings"

	$scope.app.dcu.promise.then (currentUser) ->
		return true
	, (error) ->
		$scope.app.flash('info', 'Log in to change your settings')
		$location.search('path', window.location.pathname)
		$location.search('search', window.location.search)
		$location.path('/login')

	$scope.saveSettings = ->
		$scope.app.show.loading = true
		success = (data) ->
			$scope.app.show.loading = false
			$scope.app.flash 'success', 'Your settings have been saved'
			analytics.track 'save settings success',
				href: window.location.href
				userId: $scope.app.currentUser.id
				userName: $scope.app.currentUser.name
		error = (error) ->
			$scope.app.show.loading = false
			$scope.app.flash 'error', error.data.errors
			analytics.track 'save settings error',
				href: window.location.href
				userId: $scope.app.currentUser.id
				userName: $scope.app.currentUser.name
				error: JSON.stringify(error)
		$scope.app.currentUser.save success, error
]




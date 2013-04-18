ps.controller "AppCtrl", ["$scope", "$timeout", "$rootScope", "$q", "User", ($scope, $timeout, $rootScope, $q, User) ->

    ######################
    # App Initialization #
    ######################
    $scope.app = {}
    $scope.app.currentUser = {}
    $scope.app.dcu = $q.defer() # Defered Current User
    $scope.app.year = (new Date).getFullYear()
    $scope.app.templates =
        loading:
            url: "/assets/app/loading.html"
        header:
            url: "/assets/app/header.html"
            classes: "navbar"
        flash:
            url: "/assets/app/flash.html"
        footer:
            url: "/assets/app/footer.html"
    $scope.app.show =
        loading: false
        focus: false
        header: true
        footer: true

    # Style count in favicon
    Tinycon.setOptions
        width: 7
        height: 9
        font: '10px arial'
        color: '#ffffff'
        background: '#00C0FF'
        fallback: true

    #Load Modernizer
    # - placeholder_polyfill
    Modernizr.load
        test: Modernizr.input.placeholder
        nope: [ 'placeholder_polyfill.min.css'
                'placeholder_polyfill.jquery.min.combo.js' ]

    # Add CSRF to all jQuery ajax
    $("body").bind "ajaxSend", (elm, xhr, s) ->
        $.rails.CSRFProtection(xhr) if s.type is "POST"


    # TODO: bootstrap this data on the angular.html.haml template and only request it if no bootstrap is found
    $scope.app.loadCurrentUser = (userData = null) ->
        # Reset the defer everytime the user is reloaded
        $scope.app.dcu = $q.defer()

        $scope.app.dcu.promise.then (data) ->
            Tinycon.setBubble data.ready_conversations_count
            analytics.identify data.id,
                name                      : data.name
                slug                      : data.slug
                body                      : data.body
                email                     : data.email
                locale                    : data.locale
                gender                    : data.gender
                username                  : data.username
                location                  : data.location
                birthday                  : data.birthday
                timezone                  : data.timezone
                createdAt                 : data.created_at
                updatedAt                 : data.updated_at
                facebookId                : data.facebook_id
                signInCount               : data.sign_in_count
                personalUrl               : data.personal_url
                lastSignInAt              : data.last_sign_in_at
                achievements              : JSON.stringify(data.achievements)
                readyConversationsCount   : data.ready_conversations_count
                endedConversationsCount   : data.ended_conversations_count
                waitingConversationsCount : data.waiting_conversations_count

        if userData?
            $scope.app.currentUser = new User userData
            $scope.app.dcu.resolve(userData)
        else
            $scope.app.currentUser = User.current $scope.app.dcu.resolve, $scope.app.dcu.reject

    $scope.app.loadCurrentUser()

    $scope.app.loggedIn = ->
        !_.isEmpty($scope.app.currentUser)
    $scope.app.anyMessages = ->
        $scope.app.loggedIn() and $scope.app.currentUser.ready_conversations_count? and $scope.app.currentUser.ready_conversations_count > 0


    #############
    # Hide/Show #
    #############
    $scope.app.show.allChrome = ->
        $scope.app.show.header = true
        $scope.app.show.footer = true
        $scope.app.show.focus = false

    $scope.app.show.noChrome = ->
        $scope.app.show.header = false
        $scope.app.show.footer = false
        $scope.app.show.focus = true

    ###################
    # On Route Change #
    ###################
    $rootScope.$on "$routeChangeStart", (event, next, current) ->
        # Make sure the chrome is visible
        $scope.app.show.allChrome()

        # Track a pageview
        analytics.pageview()
        analytics.track 'page viewed',
            href: window.location.href

        # Autosize all textareas
        # $timeout (() -> $('textarea').autosize()), 1000


    #########
    # Flash #
    #########
    $scope.app.alerts = {}
    $scope.app.flash = (type, msg, options={}) ->
        key = options.key or null
        sticky = if options.sticky == true then true else false
        clearAll = if options.clearAll == false then false else true

        if clearAll then $scope.app.alerts = {}

        if _.isString(msg)
            if key? then msg = [key, msg].join(" ")
            id = _.uniqueId('flash_')
            $scope.app.alerts[id] = {type: "#{type} animated fadeInRightBig", msg: msg}
            # rm animated styles once it's loaded - they cause it to reanimate when another alert is deleted
            $timeout () ->
                if $scope.app.alerts[id]?
                    $scope.app.alerts[id].type = $scope.app.alerts[id].type.split(" ")[0]
            ,1000
            # auto close the alert after a bit of time
            unless sticky
                time = 2222 + (111 * msg.length) + (2000 * _.keys($scope.app.alerts).length)
                $timeout () ->
                    $scope.app.closeAlert(id, true)
                ,time
        else if _.isArray(msg)
            _.each msg, (m, i) ->
                $scope.app.flash(type, m, {key: key, clearAll: false})
        else if _.isObject(msg)
            i = 0
            _.each msg, (v, k) ->
                $timeout () ->
                    $scope.app.flash(type, v, {key: k, clearAll: false})
                , 300*i
                i += 1

    $scope.app.closeAlert = (id, fade=false) ->
        if $scope.app.alerts[id]?
            type = $scope.app.alerts[id].type.split(" ")[0]
            $scope.app.alerts[id].type = "#{type} animated fadeOut"
            if fade
                $timeout () ->
                    delete $scope.app.alerts[id]
                ,444
            else
                delete $scope.app.alerts[id]


    #############
    # User Auth #
    #############
    $scope.app.logout = ->
        $scope.app.currentUser = User.logout ->
            window.location.reload()
            $scope.app.show.loading = true
            $scope.app.flash 'info', "Bye, hope to see you again soon."

    $scope.app.resetPassword = (login) ->
        # TODO: handle the reset password link page in angular
        $scope.app.show.loading = true
        User.resetPassword
            user:
                login: login
            (data) ->
                $scope.app.show.loading = false
                $scope.app.flash 'info', "Check your inbox (including your spam folder) for password reset instructions. The email should arrive in less than a minute.", {sticky: true}
            (error) ->
                $scope.app.show.loading = false
                $scope.app.flash 'error', "Sorry, that <em>email address or username</em> is not registered with us. Please try again or <a href='/register' class='unfancy-link'>request a new account</a>."
                $input = $('input.forgot-password:visible')
                $input.focus()
                $input.addClass('animated shake')
                $timeout () ->
                    $input.removeClass('shake')
                ,1000


]


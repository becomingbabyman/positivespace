ps.controller "AppCtrl", ["$scope", "$timeout", "User", ($scope, $timeout, User) ->
    
    ######################
    # App Initialization #
    ######################
    $scope.app = {}
    $scope.app.currentUser = {}
    $scope.app.preLogin = {rememberMe: true}
    $scope.app.templates =
        header:
            url: "/assets/app/header.html"
            classes: "navbar"
        flash:
            url: "/assets/app/flash.html"
        footer:
            url: "/assets/app/footer.html"

    # TODO: bootstrap this data on the angular.html.haml template and only request it if no bootstrap is found
    $scope.app.currentUser = User.current()


    #########
    # Flash #
    #########
    $scope.app.alerts = {}
    $scope.app.flash = (type, msg, key=null, clear=true) ->
        if clear then $scope.app.alerts = {}
        if _.isString(msg)
            if key? then msg = [key, msg].join(" ")
            id = _.uniqueId('flash_')
            $scope.app.alerts[id] = {type: "#{type} animated fadeInRightBig", msg: msg}
            # rm animated styles once it's loaded - they cause it to reanimate when another alert is deleted 
            $timeout () ->
                $scope.app.alerts[id].type = $scope.app.alerts[id].type.split(" ")[0]
            ,1000
            # auto close the alert after a bit of time
            time = 12000 + (2000 * _.keys($scope.app.alerts).length)
            $timeout () ->
                $scope.app.closeAlert(id)
            ,time
        else if _.isArray(msg)
            _.each msg, (m, i) ->
                $scope.app.flash(type, m, key, false)
        else if _.isObject(msg)
            i = 0
            _.each msg, (v, k) ->
                $timeout () ->
                    $scope.app.flash(type, v, k, false)
                , 300*i
                i += 1
    $scope.app.closeAlert = (id) ->
        if $scope.app.alerts[id]?
            type = $scope.app.alerts[id].type.split(" ")[0]
            $scope.app.alerts[id].type = "#{type} animated fadeOut"
            $timeout () ->
                delete $scope.app.alerts[id]
            ,444


    #############
    # User Auth #
    #############
    $scope.app.register = (email = $scope.app.preLogin.email, username = $scope.app.preLogin.username, password = $scope.app.preLogin.password, rememberMe = $scope.app.preLogin.rememberMe) ->
        # TODO: auto switch to login if the email address belongs to an existing user
        # TODO: check that the username is not taken and show error if it is
        User.register
            user:
                email: email
                username: username
                password: password
                remember_me: rememberMe
            (data) ->
                $scope.app.currentUser = data
                $scope.app.preLogin = {}
                $scope.app.flash 'success', "Welcome. Please follow the instructions to set up your positive space."
            (error) ->   
                $scope.app.flash 'error', error.data.errors

    $scope.app.login = (login = $scope.app.preLogin.login, password = $scope.app.preLogin.password, rememberMe = $scope.app.preLogin.rememberMe) ->
        User.login
            user:
                login: login
                password: password
                remember_me: rememberMe
            (data) ->
                $scope.app.currentUser = data
                $scope.app.preLogin = {}
                $scope.app.flash 'success', "Welcome back!"
            (error) ->
                $scope.app.flash 'error', "Oops, that's the wrong username or password."

    $scope.app.logout = ->
        $scope.app.currentUser = User.logout()
        $scope.app.flash 'info', "Bye, hope to see you again soon."

    $scope.app.resetPassword = (login = $scope.app.preLogin.login) ->
        # TODO: handle the reset password link page in angular
        User.resetPassword
            user:
                login: login
            (data) ->
                $scope.app.preLogin = {}
                $scope.app.flash 'info', "Check your inbox (and spam folder) for password reset instructions. They should arrive in less than a minute." 
            (error) ->
                $scope.app.flash 'error', error.data.errors


]


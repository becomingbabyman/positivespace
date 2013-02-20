ps.controller "AppCtrl", ["$scope", "$timeout", "User", ($scope, $timeout, User) ->
    
    ######################
    # App Initialization #
    ######################
    $scope.app = {}
    $scope.app.currentUser = {}
    $scope.app.year = (new Date).getFullYear()
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


    $scope.app.loggedIn = ->
        !_.isEmpty($scope.app.currentUser)

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
            time = (111 * msg.length) + (2000 * _.keys($scope.app.alerts).length)
            $timeout () ->
                $scope.app.closeAlert(id, true)
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
        $scope.app.currentUser = User.logout()
        $scope.app.flash 'info', "Bye, hope to see you again soon."

    $scope.app.resetPassword = (login) ->
        # TODO: handle the reset password link page in angular
        User.resetPassword
            user:
                login: login
            (data) ->
                $scope.app.flash 'info', "Check your inbox (including your spam folder) for password reset instructions. The email should arrive in less than a minute." 
            (error) ->
                $scope.app.flash 'error', "We're sorry, your <em>email or username</em> is not registered. You should request an invite!"


]


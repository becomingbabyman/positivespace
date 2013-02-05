root = global ? window

CsrfCtrl = ($cookieStore) ->
  $cookieStore.put "XSRF-TOKEN", angular.element(document.getElementById("csrf")).attr("data-csrf")

CsrfCtrl.$inject = ['$cookieStore'];

# exports
root.CsrfCtrl = CsrfCtrl
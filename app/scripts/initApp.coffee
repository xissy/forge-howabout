
# app configuration
howaboutApp.config [
  '$routeProvider'
  '$locationProvider'
  ($routeProvider, $locationProvider) ->
    $routeProvider
    .when '/',
      templateUrl: 'views/main.html'
      controller: 'MainController'
    .otherwise
      redirectTo: '/'

]

# boostrapping
angular.bootstrap document, [ 'howaboutApp' ]


# Services
howaboutServices = angular.module 'howaboutServices', ['ng', 'ngResource']
apiHost = 'http://listena.recom.io'

# App
howaboutApp = angular.module 'howaboutApp', [ 'ngRoute', 'howaboutServices' ]

# CORS
howaboutApp.config [
  '$httpProvider'
  ($httpProvider) ->
    $httpProvider.defaults.useXDomain = true
    delete $httpProvider.defaults.headers.common['X-Requested-With']
]

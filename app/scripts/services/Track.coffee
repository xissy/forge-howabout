
howaboutServices.factory 'Track', [
  '$resource'
  ($resource) ->
    $resource "#{apiHost}/tracks/:trackId",
      trackId: '@id'
    ,
      get:
        method: 'GET'
      listRandom:
        method: 'GET'
        isArray: true
        params:
          trackId: 'random'
          limit: '50'
      search:
        method: 'GET'
        isArray: true
        params:
          trackId: 'search'
          limit: '50'
          
]

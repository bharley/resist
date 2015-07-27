app = angular.module('resist', ['ui.router', 'ui.bootstrap']).config [
  '$stateProvider', '$urlRouterProvider', '$urlMatcherFactoryProvider', '$locationProvider', '$provide',
  ($stateProvider,   $urlRouterProvider,   $urlMatcherFactoryProvider,   $locationProvider,   $provide) ->
    # Turn on HTML5 url mode
    $locationProvider.html5Mode true

    # Allow matching with slashes at the end of a URL
    $urlMatcherFactoryProvider.strictMode false

    # 404 on missing pages
    $urlRouterProvider.otherwise ($injector, $location) ->
      $injector.invoke [
        '$state',
        ($state) -> $state.go '404'
      ]

    # Set up our states/routes
    $stateProvider
      # Lobby
      .state 'lobby',
        url:         '^/'
        templateUrl: 'lobby.html'
        controller:  'LobbyController as lobby'
        options:
          title: 'Game Lobby'

      # Game
      .state 'game',
        templateUrl: 'game.html'
        controller:  'GameController as game'
        options:
          title: 'Game'

      # 404 state
      .state '404',
        templateUrl: '404.html'
        options:
          title: 'Page not found'

    # Adds the 'success' and 'error' convenience methods that the $http promises have
    $provide.decorator '$q', [
      '$delegate',
      ($delegate) ->
        defer = $delegate.defer

        $delegate.defer = ->
          deferred = defer()

          deferred.promise.success = (fn) ->
            deferred.promise.then fn
            return deferred.promise

          deferred.promise.error = (fn) ->
            deferred.promise.then null, fn
            return deferred.promise

          return deferred

        return $delegate
    ]
]

app.run [
  '$rootScope', '$state', 'GameClient',
  ($rootScope,   $state,   game) ->
    # We pop the game server in here to ensure it is loaded immediately
]
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

      # Game - Phase one
      .state 'game-team-select',
        templateUrl: 'game-1.html'
        controller:  'GamePhaseOneController as game'

      # Game - Phase two
      .state 'game-team-vote',
        templateUrl: 'game-2.html'
        controller:  'GamePhaseTwoController as game'

      # Game - Phase three
      .state 'game-post-team-vote',
        templateUrl: 'game-3.html'
        controller:  'GamePhaseThreeController as game'

      # Game - Phase four
      .state 'game-mission',
        templateUrl: 'game-4.html'
        controller:  'GamePhaseFourController as game'

      # Game - Phase five
      .state 'game-post-mission',
        templateUrl: 'game-5.html'
        controller:  'GamePhaseFiveController as game'

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
  '$rootScope', '$state', '$modalStack', 'GameClient',
  ($rootScope,   $state,   $modalStack,   game) ->

    # Look for state changes to close out our modals
    $rootScope.$on '$stateChangeStart', ->
      $modalStack.dismissAll()
]
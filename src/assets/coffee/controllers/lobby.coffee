angular.module('resist').controller 'LobbyController', [
  '$state', '$log', '$scope', '$timeout', '$modal', 'GameClient',
  ($state,   $log,   $scope,   $timeout,   $modal,   game) -> new class LobbyController
    constructor: ->
      @playerId = game.playerId
      @players = game.players
      @ready = if @players then @players[@playerId]?.ready else false

      $scope.$on 'connected', (event, playerId) =>
        $timeout => @playerId = playerId

      $scope.$on 'players.change', (event, players) =>
        $timeout =>
          @players = players
          @ready = @players[@playerId]?.ready

    toggleReady: =>
      game.toggleReady()
      @ready = @players[@playerId]?.ready

    changeName: =>
      $modal.open
        templateUrl: 'changeNameModal'
        controller:  'ChangeNameController as modal'
        resolve:
          oldName: => @players[@playerId]?.name
      .result.then (newName) ->
        game.changeName newName
]

angular.module('resist').controller 'ChangeNameController', [
  '$modalInstance', 'oldName',
  ($modalInstance,   oldName) -> new class ChangeNameController
    constructor: ->
      @name = oldName

    changeName: =>
      $modalInstance.close @name

    cancel: ->
      $modalInstance.dismiss 'cancel'
]

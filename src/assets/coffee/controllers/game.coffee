app = angular.module 'resist'

class GamePhaseController
  constructor: ($state, $scope, $timeout, gameClient) ->
    # Make sure we have a game going before we do anything
    if !gameClient.players || !gameClient.playerId
      $state.go 'lobby'

    # Attach stuff game controllers usually need
    @playerId     = gameClient.playerId
    @players      = gameClient.players
    @mission      = gameClient.mission
    @intermission = gameClient.intermission()

    # Listen for player changes
    $scope.$on 'players.change', (event, players) => $timeout =>
      @players = players

    # Register some helper functions
    @isSpy = -> gameClient.isSpy()
    @isLeader = -> gameClient.isLeader()

# Phase one - The team building phase
app.controller 'GamePhaseOneController', [
  '$state', '$scope', '$timeout', '$modal', 'GameClient', 'SharedResources',
  ($state,   $scope,   $timeout,   $modal,   gameClient,   shared) -> new class GamePhaseOneController extends GamePhaseController
    constructor: ->
      super $state, $scope, $timeout, gameClient

      # Show the intro modal on the first vote of the first mission
      if @mission is 1 && gameClient.votes is 0
        $modal.open
          templateUrl: 'modals/intro.html'
          controller:  'IntroModalController as modal'
          resolve:
            isSpy:    => @isSpy()
            spyCount: => shared.spyCount Object.keys(@players).length

    # Picks a member to go on the next mission
    pickMember: (playerId) -> gameClient.toggleMemberForMission playerId

    # Locks the current mission team
    lockTeam: -> gameClient.lockTeam()

    # Calculates the current mission team size
    teamSize: -> gameClient.teamSize()

    # The current mission team
    getTeam: -> gameClient.getTeam()

    # Whether or not the mission team has enough players
    teamFull: => @getTeam().length is @teamSize()
]

# Phase two - Time to vote on this team comp!
app.controller 'GamePhaseTwoController', [
  '$state', '$scope', '$timeout', '$modal', 'GameClient',
  ($state,   $scope,   $timeout,   $modal,   gameClient) -> new class GamePhaseTwoController extends GamePhaseController
    constructor: ->
      super $state, $scope, $timeout, gameClient

      # Vote on this team
      modal = $modal.open
        templateUrl: 'modals/vote.html'
        controller:  'VoteModalController as modal'
        keyboard:    false
        backdrop:    'static'
        resolve:
          team: -> gameClient.getTeam().map (p) -> p.name
      modal.result.then (accept) =>
        gameClient.teamVote accept
      , =>
        gameClient.teamVote false
]

# Phase three - Shows the players the outcome of the vote
app.controller 'GamePhaseThreeController', [
  '$state', '$scope', '$timeout', 'GameClient',
  ($state,   $scope,   $timeout,   gameClient) -> new class GamePhaseThreeController extends GamePhaseController
    constructor: ->
      super $state, $scope, $timeout, gameClient

      @voteSuccess = gameClient.lastVoteResult

      $scope.$on 'vote.result', (event, result) => $timeout =>
        @voteSuccess = result
]

# Phase four - The mission members vote on whether or not the mission succeeds
app.controller 'GamePhaseFourController', [
  '$state', '$scope', '$timeout', '$modal', 'GameClient',
  ($state,   $scope,   $timeout,   $modal,   gameClient) -> new class GamePhaseFourController extends GamePhaseController
    constructor: ->
      super $state, $scope, $timeout, gameClient

      @onMission = gameClient.isOnMission()
      if @onMission
        modal = $modal.open
          templateUrl: 'modals/mission.html'
          controller:  'MissionModalController as modal'
          keyboard:    false
          backdrop:    'static'
          resolve:
            isSpy: -> gameClient.isSpy()
        modal.result.then (accept) =>
          gameClient.missionReport accept
        , =>
          gameClient.missionReport true
]

# Phase five - Shows the players the outcome of the mission
app.controller 'GamePhaseFiveController', [
  '$state', '$scope', '$timeout', 'GameClient',
  ($state,   $scope,   $timeout,   gameClient) -> new class GamePhaseFiveController extends GamePhaseController
    constructor: ->
      super $state, $scope, $timeout, gameClient
]

app.controller 'IntroModalController', [
  '$modalInstance', '$scope', 'isSpy', 'spyCount',
  ($modalInstance,   $scope,   isSpy,   spyCount) -> new class IntroModalController
    constructor: ->
      $scope.isSpy = isSpy
      $scope.spyCount = spyCount

    close: ->
      $modalInstance.dismiss 'cancel'
]

app.controller 'VoteModalController', [
  '$modalInstance', 'team',
  ($modalInstance,   team) -> new class VoteModalController
    constructor: -> @team = team

    accept: -> $modalInstance.close true
    reject: -> $modalInstance.close false
]

app.controller 'MissionModalController', [
  '$modalInstance', 'isSpy',
  ($modalInstance,   isSpy) -> new class MissionModalController
    constructor: -> @isSpy = isSpy

    success: -> $modalInstance.close true
    fail: -> $modalInstance.close false
]


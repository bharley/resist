angular.module('resist').controller 'GameController', [
  '$state', '$log', '$scope', '$timeout', '$modal', 'GameClient', 'SharedResources',
  ($state,   $log,   $scope,   $timeout,   $modal,   game,         shared) -> new class GameController
    constructor: ->
      @playerId = game.playerId
      @players = game.players
      @state = game.state
      @mission = game.mission
      @votes = game.votes
      @voteSuccess = null
      @shared = shared

      if !@players || !@playerId
        $state.go 'lobby'

      # Show the intro modal
      modal = $modal.open
        templateUrl: 'introModal'
        controller:  'IntroModalController as modal'
        resolve:
          isSpy:    => @isSpy()
          spyCount: => shared.spyCount Object.keys(@players).length

      # Listen for player model changes
      $scope.$on 'players change', (event, players) => $timeout =>
        @players = players

      # Listen for state changes
      $scope.$on 'state change', (event, state) => $timeout =>
        @state = state

        # Handle state changes
        if state is shared.STATE.TEAM_VOTE
          modal?.dismiss 'cancel'
          modal = $modal.open
            templateUrl: 'voteModal'
            controller:  'VoteModalController as modal'
            keyboard:    false
            backdrop:    'static'
            resolve:
              team: => @getTeam().map (p) -> p.name
          modal.result.then (accept) =>
            game.teamVote accept
          , =>
            game.teamVote false

      $scope.$on 'vote result', (event, result) => $timeout =>
        modal?.dismiss 'cancel'
        @voteSuccess = result

    # Picks a member to go on the next mission
    pickMember: (playerId) => game.toggleMemberForMission playerId

    # Locks the current mission team
    lockTeam: => game.lockTeam()

    # Whether or not this player is a spy
    isSpy: => game.isSpy()

    # Whether or not this player is the current leader
    isLeader: => game.isLeader()

    # Calculates the current mission team size
    teamSize: => game.teamSize()

    # The current mission team
    getTeam: => game.getTeam()

    # Whether or not the mission team has enough players
    teamFull: => @getTeam().length is @teamSize()

    showTip: => @state is shared.STATE.TEAM_SELECT || @state is shared.STATE.POST_TEAM_VOTE

    # Gets range for the view
    getRange: (n) -> [1..n]
]

angular.module('resist').controller 'IntroModalController', [
  '$modalInstance', '$scope', 'isSpy', 'spyCount',
  ($modalInstance,   $scope,   isSpy,   spyCount) -> new class IntroModalController
    constructor: ->
      $scope.isSpy = isSpy
      $scope.spyCount = spyCount

    close: ->
      $modalInstance.dismiss 'cancel'
]

angular.module('resist').controller 'VoteModalController', [
  '$modalInstance', 'team',
  ($modalInstance,   team) -> new class VoteModalController
    constructor: -> @team = team

    accept: -> $modalInstance.close true
    reject: -> $modalInstance.close false
]

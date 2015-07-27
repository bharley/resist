angular.module('resist').factory 'GameClient', [
  '$state', '$window', '$rootScope', 'SharedResources',
  ($state,   $window,   $rootScope,   shared) -> new class GameClient
    io = null

    constructor: ->
      # Set up the connection to the web socket server
      io = $window.io()

      # Maintain a list of players and ourself
      @playerId = null
      @players = null
      @state = shared.STATE.SETUP
      @mission = 1
      @votes = 0
      @lastVoteResult = null
      @roundWins = []

      @setupLobby()

      # Listen for changes to game mode
      handleStateChange = (state) =>
        @state = state
        $state.go 'game-' + state.replace(/ /g, '-').toLowerCase()
        console.log "Game is changing states: #{state}"

      io.on 'game/start', handleStateChange
      io.on 'game/state', handleStateChange

      io.on 'game/vote-result', (result) =>
        @votes++
        @lastVoteResult = result
        $rootScope.$broadcast 'vote.result', result

      io.on 'game/mission-vote', ({mission, vote}) =>
        @mission = mission
        @votes = vote

      # Listen for leadership changes
      io.on 'player/new-leader', (playerId) =>
        for id, player of @players
          player.leader = id is playerId
        @playersUpdated()

      # Accept updates to the scores
      io.on 'game/score', (wins) =>
        @roundWins = wins

      # Listen for changes to player data
      io.on 'player/patch', ({playerId, delta}) =>
        if @players[playerId]
          p = @players[playerId]
          console.log "Incoming patch for #{p.name}:"
          console.log delta

        @players[playerId] = {} if not @players[playerId]
        for key, value of delta
          @players[playerId][key] = value
        @playersUpdated()


    # Sets up lobby listeners and other things
    setupLobby: =>
      # Listen for our connection
      io.on 'lobby/connected', ({player, players}) =>
        @playerId = player
        @players = {}
        for p in players
          @players[p.id] = p
        $rootScope.$broadcast 'connected', player
        @playersUpdated()
      io.on 'reconnect', -> $state.go 'lobby'

      io.on 'lobby/leave', (playerId) =>
        delete @players[playerId]
        @playersUpdated()

    # Tells the world that the player list has changed in some way
    playersUpdated: =>
      $rootScope.$broadcast 'players.change', @players

    # Tell the server we want to change our name
    changeName: (name) ->
      io.emit 'lobby/change-name', name

    # Toggle this player's ready state
    toggleReady: =>
      io.emit 'lobby/ready'
      @players[@playerId].ready = !@players[@playerId].ready
      @playersUpdated()

    # Tell the server about a team selection
    toggleMemberForMission: (playerId) =>
      return if !@isLeader()

      io.emit 'game/pick-member', playerId
      @players[playerId].onMission = !@players[playerId].onMission
      @playersUpdated()

    # Send the lock team event to the server
    lockTeam: =>
      return if !@isLeader()

      io.emit 'game/lock-mission'

    # Tell the server our vote
    teamVote: (accept) =>
      @players[@playerId].vote = if accept then 'accept' else 'reject'
      io.emit 'game/team-vote', accept

    # Tell the server what we did during the mission
    missionReport: (success) =>
      return if !@isOnMission()
      io.emit 'game/mission-report', success

    # Whether or not this player is a spy
    isSpy: => @players[@playerId]?.role is 'spy'

    # Whether or not this player is the current leader
    isLeader: => !!@players[@playerId]?.leader

    # Whether or not this player is on the mission
    isOnMission: => !!@players[@playerId]?.onMission

    # The team size this mission needs
    teamSize: => shared.teamSize Object.keys(@players).length, @mission

    # The number of seconds the intermission will last
    intermission: -> shared.INTERMISSION / 1000

    # The current team
    getTeam: =>
      team = []
      for id, player of @players
        team.push(player) if player.onMission
      team
]

# Includes
utils  = require './utils'
shared = require '../assets/coffee/shared.coffee'

class Game
  state          = shared.STATE.SETUP
  mission        = 0
  roundWins      = []
  voteRounds     = 0
  missionReports = {}

  constructor: (@io, @players) ->
    # Determine who is a spy and who isn't
    spyCount = shared.spyCount @players.length
    spies = @players.shuffle()[0..spyCount-1]
    player.role = 'spy' for player in spies

    # Notify the spies of each other
    for player in spies
      for spy in spies
        player.emit 'player/patch',
          playerId: spy.id
          delta:
            role: spy.role

    # Start the first round
    @newRound(true, false)

    # Set up the listeners for everyone
    for player in @players
      player.on 'game/pick-member',    @selectTeamMember
      player.on 'game/lock-mission',   @lockMission
      player.on 'game/team-vote',      @teamVote
      player.on 'game/mission-report', @missionReport

    # Let the clients know the game has started
    state = shared.STATE.TEAM_SELECT
    @io.sockets.emit 'game/start', state

  # Takes care of things that happen at the start of a new round
  newRound: (newMission = true, changeState = true) =>
    if newMission
      mission++
      voteRounds = 0
      missionReports = {}
    else
      voteRounds++

    # If the 5th vote failed, the spies get a point
    if voteRounds >= 5
      @addWin 'spy'
      @newRound()

    # Send this except on the very first mission
    if mission isnt 0 || voteRounds isnt 0
      @io.sockets.emit 'game/mission-vote',
        mission: mission
        vote:    voteRounds

    # Choose the next/first leader
    leaderIndex = @players.findBy (p) -> p.leader is true
    leader = if leaderIndex is false
      # This is the first round, choose the first leader
      @players.shuffle()[0]
    else
      # Move to the next leader
      @players[leaderIndex].leader = false
      leaderIndex++
      leaderIndex = 0 if leaderIndex >= @players.length
      @players[leaderIndex]
    leader.leader = true
    @io.sockets.emit 'player/new-leader', leader.id

    # Reset the votes and mission members
    @players.map (p) =>
      p.vote = false
      p.onMission = false
      @io.sockets.emit 'player/patch',
        playerId: p.id
        delta:
          vote: p.vote
          onMission: p.onMission

    # Let the clients know a new round started
    if changeState
      @changeState shared.STATE.TEAM_SELECT

  # Toggles whether or not a player is on a mission
  selectTeamMember: (socket) => (playerId) =>
    player = @getPlayer socket.id
    return if !player.leader # Only the leader can select mission members

    picked = @getPlayer playerId
    picked.onMission = !picked.onMission
    socket.broadcast.emit 'player/patch',
      playerId: playerId
      delta:
        onMission: picked.onMission

  # Moves to the team voting stage if we meet the requirements
  lockMission: (socket) => =>
    player = @getPlayer socket.id
    return if !player.leader # Only the leader can do this
    return if @getMissionMembers().length isnt shared.teamSize(@players.length, mission) # Only do this if we meet the size requirements

    @changeState shared.STATE.TEAM_VOTE

  # The player voted!
  teamVote: (socket) => (accept) =>
    return if state isnt shared.STATE.TEAM_VOTE # We don't care about votes right now...
    player = @getPlayer socket.id
    return if player.vote isnt false # Hey... you already voted!

    player.vote = if accept then 'accept' else 'reject'

    # If everyone voted, reveal the results
    if (@players.filter (p) -> p.vote isnt false).length is @players.length
      @players.map (p) =>
        @io.sockets.emit 'player/patch',
          playerId: p.id
          delta:
            vote: p.vote

      acceptVotes = (@players.filter (p) -> p.vote is 'accept').length
      voteSuccess = (acceptVotes / @players.length) > 0.5

      utils.log.debug "All votes are in, and the vote did#{if voteSuccess then '' else ' not'} succeed"

      @io.sockets.emit 'game/vote-result', voteSuccess
      @changeState shared.STATE.POST_TEAM_VOTE

      # After 10 seconds, go to the next round
      setTimeout =>
        # If the vote succeeded, go to the mission stage
        if voteSuccess
          @changeState shared.STATE.MISSION
        else
          @newRound false
      , shared.INTERMISSION
    else
      player.broadcast 'player/patch',
        playerId: player.id
        delta:
          vote: true # For now, only tell the other players that I voted

  # Handles a player reporting in from a mission
  missionReport: (socket) => (success) =>
    return if state isnt shared.STATE.MISSION # We don't care about missions right now...
    player = @getPlayer socket.id
    return if !player.onMission # Hey, you can't participate...
    return if missionReports[player.id] # Hey, you already reported in...

    # Accept the report (note that non-spies can only report a success)
    missionReports[player.id] = if player.isSpy() then success else true

    # Determine if everyone reported in
    if @getMissionMembers().length is Object.keys(missionReports).length
      missionSuccess = (report for id, report of missionReports).reduce (a, b) -> a && b
      utils.log.debug "All reports are in, and the mission did#{if missionSuccess then '' else ' not'} succeed"

      @addWin if missionSuccess then 'resistance' else 'spy'
      @io.sockets.emit 'game/mission-result', missionSuccess
      @changeState shared.STATE.POST_MISSION

      # After 10 seconds, clear the board
      setTimeout =>
        @newRound()
      , shared.INTERMISSION

  # Gets the members that are part of the current mission
  getMissionMembers: => @players.filter (p) -> p.onMission

  # Looks up a player by their socket id
  getPlayer: (id) -> @players[@players.findBy (p) -> p.id is id]

  # Sends the scores out to everyone
  addWin: (winner) =>
    roundWins.push winner
    @io.sockets.emit 'game/score', roundWins

  # Change state helper
  changeState: (newState) =>
    state = newState
    @io.sockets.emit 'game/state', state

module.exports = Game

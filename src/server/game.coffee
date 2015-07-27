# Includes
utils  = require './utils'
shared = require '../assets/coffee/shared.coffee'

class Game
  state      = shared.STATE.SETUP
  mission    = 0
  voteRounds = 0

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
      player.on 'game/pick-member', @selectTeamMember
      player.on 'game/lock-mission', @lockMission
      player.on 'game/team-vote', @teamVote

    # Let the clients know the game has started
    state = shared.STATE.TEAM_SELECT
    @io.sockets.emit 'game/start', state

  # Takes care of things that happen at the start of a new round
  newRound: (newMission = true, changeState = true) =>
    if newMission
      voteRounds = 0
      mission++

    # Choose the next/first leader
    leaderIndex = @players.findBy (p) -> p.leader is true
    leader = if not leaderIndex
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
      changeState shared.STATE.TEAM_SELECT

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

      utils.log.debug "All votes are in, and the vote did #{if voteSuccess then '' else 'not'} succeed"

      @io.sockets.emit 'game/vote-result', voteSuccess
      @changeState shared.STATE.POST_TEAM_VOTE

      # After 10 seconds, clear the board
      setTimeout =>
        # If the vote succeeded, go to the mission stage
        if voteSuccess
          @changeState shared.STATE.MISSION
        else
          @newRound false
      , 10000
    else
      player.broadcast 'player/patch',
        playerId: player.id
        delta:
          vote: true # For now, only tell the other players that I voted

  # Gets the members that are part of the current mission
  getMissionMembers: => @players.filter (p) -> p.onMission

  # Looks up a player by their socket id
  getPlayer: (id) -> @players[@players.findBy (p) -> p.id is id]

  # Change state helper
  changeState: (newState) =>
    state = newState
    @io.sockets.emit 'game/state', state

module.exports = Game

# Includes
utils  = require './utils'
Player = require './player'
Game   = require './game'

STATE =
  LOBBY: 0
  game:  1

# Game Server class
class GameServer
  state   = STATE.LOBBY
  players = []
  game    = null

  # Set up the game server
  constructor: (@io) ->
    @io.on 'connection', (socket) => @connectionHandler(socket)

  # Handles new players connecting to the game
  connectionHandler: (socket) =>
    # Do not allow new connections when a game is in progress or there are 10 players
    if state isnt STATE.LOBBY || players.length >= 10
      socket.disconnect 'Game in progress'
      return

    # Set up the new player
    player = new Player socket
    players.push player
    utils.log.info "User \"#{player.name}\" connected"

    # Listen for that disconnect
    player.on 'disconnect', @disconnect

    # Listen for lobby commands
    player.on 'lobby/change-name', @changeName
    player.on 'lobby/ready', @readyUp

    # Broadcast the player's arrival
    socket.emit 'lobby/connected',
      player:  player.id
      players: players.map((p) -> p.props())
    socket.broadcast.emit 'player/patch',
      playerId: player.id
      delta:    player.props()

  # Allows a player to change their name
  changeName: (socket) => (name) =>
    player = @getPlayer socket.id
    utils.log.debug "Player #{player.name} wants to change their name to #{name}"

    # Do some validation
    return if typeof(name) isnt 'string' || name.length <= 0 # Make sure we got something valid-ish
    return if player.ready # Ready player's can't change names
    name = name[0..23] if name.length > 24 # Cap name lengths
    i = players.findBy (p) -> p.name is name # Make sure they aren't stealing someone else's name
    return if i isnt false

    player.name = name
    @io.sockets.emit 'player/patch',
      playerId: player.id
      delta:
        name: name

  # Handles the player toggling their ready state
  readyUp: (socket) => =>
    player = @getPlayer socket.id
    player.ready = !player.ready
    socket.broadcast.emit 'player/patch',
      playerId: player.id
      delta:
        ready: player.ready

    if @allPlayersReady() && players.length >= 5
      utils.log.debug "All players are ready"
      # todo: Delay this action to allow people to un-ready
      @startGame()

  # Looks up a player by their socket id
  getPlayer: (id) -> players[players.findBy (p) -> p.id is id]

  # Whether or not all of the players are ready
  allPlayersReady: ->
    players.map((p) -> p.ready).reduce (a, b) -> a and b

  # Handles a player disconnecting
  disconnect: (socket) => =>
    index = players.findBy (p) -> p.id is socket.id
    if index isnt false
      player = players[index]
      utils.log.debug "User \"#{player.name}\" disconnected"
      players.splice index, 1
      socket.broadcast.emit 'lobby/leave', socket.id

  startGame: ->
    state = STATE.GAME
    game = new Game(@io, players)

module.exports = GameServer

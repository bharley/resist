# Includes
utils       = require './utils'
SocketProps = require './socket-props'
Moniker     = require 'moniker'
moniker     = Moniker.generator([Moniker.adjective, Moniker.noun], glue: ' ')

# Generates a player's name
makeName = ->
  moniker.choose().uppercaseWords()

# Player class
class Player extends SocketProps
  constructor: (@_socket) ->
    @id        = @_socket.id
    @name      = makeName()
    @ready     = false
    @role      = 'resistance'
    @leader    = false
    @onMission = false
    @vote      = false

  # Socket helpers
  emit: (args...) => @_socket.emit args...
  broadcast: (args...) => @_socket.broadcast.emit args...
  on: (name, handler) => @_socket.on name, handler(@_socket)

module.exports = Player

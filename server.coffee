# Set up the CoffeeScript includes
require 'coffee-script/register'

# Includes
express    = require 'express'
http       = require 'http'
socket     = require 'socket.io'
utils      = require './src/server/utils'
GameServer = require './src/server/game-server'

# Set up the application servers
app    = express()
server = http.Server app
io     = socket server

# Handle static files
app.use '/assets', express.static('build')

# Send off the index file
app.get '/', (req, res) ->
  res.sendfile 'src/public/index.html'

# Register the game server
gs = new GameServer io

# Start up the express server
server.listen 3000, ->
  console.log 'listening on *:3000'

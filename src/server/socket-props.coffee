# Simple class that provides exporting for sockets
class SocketProps
  props: =>
    props = {}
    for key, value of @
      props[key] = value if key[0] isnt '_' && typeof(value) isnt 'function'

    props

module.exports = SocketProps

# -- Array prototype
Array.prototype.findBy = (fn) ->
  for v, k in @
    return k if typeof(v) is 'object' && fn(v)

  false

Array.prototype.shuffle = ->
  a = @.slice 0
  i = a.length
  while --i > 0
      j = ~~(Math.random() * (i + 1))
      t = a[j]
      a[j] = a[i]
      a[i] = t
  a

# -- String prototype
String.prototype.padLeft = (length, char = ' ') ->
  Array(Math.max(length - @length + 1, 0)).join(char) + this

String.prototype.uppercaseWords = ->
  uppFn = (word) -> if word.length > 0 then word[0].toUpperCase() + word[1..-1].toLowerCase() else ''
  (@.split(' ').map uppFn).join ' '


# -- Logging
class Logging
  typemap = 
    debug:   'DEBG'
    info:    'INFO'
    error:   'ERRO'
    warning: 'WARN'

  timestamp = (date) ->
    parts = [date.getHours(), date.getMinutes(), date.getSeconds()]
    parts.map((t) -> ('' + t).padLeft(2, '0')).join ':'

  log = (type, message) ->
    console.log "#{timestamp(new Date)} [#{typemap[type]}] #{message}"

  debug:   (message) -> log 'debug',   message
  info:    (message) -> log 'info',    message
  error:   (message) -> log 'error',   message
  warning: (message) -> log 'warning', message


# -- Misc
module.exports = new class Utils
  log: new Logging

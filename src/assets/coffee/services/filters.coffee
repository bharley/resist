app = angular.module('resist')

# Filter for displaying the "length" of an object
app.filter 'objLength', -> (input) ->
  return 0 if !angular.isObject(input)

  Object.keys(input).length

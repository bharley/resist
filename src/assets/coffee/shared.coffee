# Resources used by both the server and client
class SharedResources
  STATE:
    SETUP:          'setup'
    TEAM_SELECT:    'team select'
    TEAM_VOTE:      'team vote'
    POST_TEAM_VOTE: 'post team vote'
    MISSION:        'mission'
    POST_MISSION:   'post mission'

  # Time that post rounds should last
  INTERMISSION: 10000

  # The number of spies a game should have given the player count
  spyCount: (playerCount) -> Math.ceil(playerCount / 3)

  # The number of team members this mission should have
  teamSize: (playerCount, mission) ->
    throw Error('Player count must be between 5 and 10, inclusive') if playerCount < 5 || playerCount > 10
    throw Error('Invalid mission number') if mission < 1 || mission > 5

    # From Wikipedia: https://en.wikipedia.org/wiki/The_Resistance_(game)#Rounds
    table = [
      [2, 2, 2, 3, 3, 3]
      [3, 3, 3, 4, 4, 4]
      [2, 4, 3, 4, 4, 4]
      [3, 3, 4, 5, 5, 5]
      [3, 4, 4, 5, 5, 5]
    ]

    table[mission - 1][playerCount - 5]

# Export this as an Angular or Node.js object
if typeof module isnt 'undefined' && module.exports
  module.exports = new SharedResources
else
  angular.module('resist').factory 'SharedResources', -> new SharedResources

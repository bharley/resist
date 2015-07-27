app = angular.module('resist')

app.directive 'playerTable', ->
  restrict:   'E'
  transclude: true
  replace:    true
  scope:      true
  template: """
<table class="table table-striped">
  <thead>
    <tr>
      <th colspan="2">Players</th>
    </tr>
  </thead>
  <tbody>
    <tr ng-repeat="player in game.players">
      <td>
        <i class="fa fa-fw" ng-class="{'fa-user': player.role === 'resistance', 'fa-user-secret': player.role === 'spy'}"></i>
        {{ player.name }}
        <span class="text-muted" ng-if="player.id === game.playerId">(You)</span>
        <i class="fa fa-fw" ng-class="{'fa-star': player.leader}"></i>
      </td>
      <td>
        <div inject></div>
      </td>
    </tr>
  </tbody>
</table>
"""

app.directive 'scoreBoard', [
  'GameClient',
  (gameClient) ->
    restrict: 'E'
    scope:    false
    link: ($scope) ->
      $scope.getRange = (n) -> [1..n]

      # Accept vote changes
      updateVote = ->
        $scope.votes = gameClient.votes
        $scope.lastVote = gameClient.lastVoteResult
      $scope.$on 'vote.result', updateVote
      updateVote()

      $scope.roundWins = gameClient.roundWins

    template: """
<table class="table table-striped">
  <thead>
    <tr>
      <th></th>
      <th ng-repeat="i in getRange(5)" class="text-center">{{ i }}</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>Votes</th>
      <td ng-repeat="i in getRange(5)" class="text-center">
        <i class="fa fa-fw" ng-class="{'fa-times-circle text-danger': i < votes || i === votes && !lastVote, 'fa-check-circle text-success': i === votes && lastVote}"></i>
      </td>
    </tr>
    <tr>
      <th>Mission</th>
      <td ng-repeat="i in getRange(5)" class="text-center">
        <i class="fa fa-fw" ng-class="{'fa-rebel text-success': roundWins[i] === 'resistance', 'fa-empire text-danger': roundWins[i] === 'spy'}"></i>
      </td>
    </tr>
  </tbody>
</table>
"""
]

# Helps with transclude not acting like I want it to
# Source: https://github.com/angular/angular.js/issues/7874#issuecomment-47647528
app.directive 'inject', ->
    link: ($scope, $element, $attrs, controller, $transclude) ->
      if !$transclude
        throw minErr('ngTransclude')('orphan',
          'Illegal use of ngTransclude directive in the template! ' +
          'No parent directive that requires a transclusion found. ' +
          'Element: {0}',
          startingTag($element)
        )

      innerScope = $scope.$new()
      $transclude innerScope, (clone) ->
        $element.empty()
        $element.append(clone)
        $element.on '$destroy', ->
          innerScope.$destroy()

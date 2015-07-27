should = require('chai').should()
shared = require '../../src/assets/coffee/shared.coffee'

describe 'SharedResources', ->
  describe '#spyCount()', ->
    it 'should be a function', ->
      shared.spyCount.should.be.a.function

    it 'should return 2 given 5 or 6', ->
      count = shared.spyCount 5

      count.should.be.an.int
      count.should.equal 2

      count = shared.spyCount 6

      count.should.be.an.int
      count.should.equal 2

    it 'should return 3 given 7, 8 or 9', ->
      count = shared.spyCount 7

      count.should.be.an.int
      count.should.equal 3

      count = shared.spyCount 8

      count.should.be.an.int
      count.should.equal 3

      count = shared.spyCount 9

      count.should.be.an.int
      count.should.equal 3

    it 'should return 4 given 10', ->
      count = shared.spyCount 10

      count.should.be.an.int
      count.should.equal 4

  describe '#teamSize()', ->
    it 'should be a function', ->
      shared.teamSize.should.be.a.function

    it 'should throw an error on invalid team size', ->
      (-> shared.teamSize(2, 1)).should.throw Error

    it 'should throw an error on an invalid mission', ->
      (-> shared.teamSize(5, 7)).should.throw Error

    it 'should return 2 for mission 1 with 7 or fewer players', ->
      sizes = [5..7].map (s) -> shared.teamSize s, 1

      sizes.map (size) ->
        size.should.be.an.int
        size.should.equal 2

    it 'should return 3 for mission 1 with 8 or more players', ->
      sizes = [8..10].map (s) -> shared.teamSize s, 1

      sizes.map (size) ->
        size.should.be.an.int
        size.should.equal 3

    it 'should return 3 for mission 2 with 7 or fewer players', ->
      sizes = [5..7].map (s) -> shared.teamSize s, 2

      sizes.map (size) ->
        size.should.be.an.int
        size.should.equal 3

    it 'should return 4 for mission 2 with 8 or more players', ->
      sizes = [8..10].map (s) -> shared.teamSize s, 2

      sizes.map (size) ->
        size.should.be.an.int
        size.should.equal 4

    it 'should return 2 for mission 3 with 5 players', ->
      size = shared.teamSize 5, 3

      size.should.be.an.int
      size.should.equal 2

    it 'should return 3 for mission 3 with 7 players', ->
      size = shared.teamSize 7, 3

      size.should.be.an.int
      size.should.equal 3

    it 'should return 4 for mission 3 with 6, 8, 9 or 10 players', ->
      sizes = [6, 8, 9, 10].map (s) -> shared.teamSize s, 3

      sizes.map (size) ->
        size.should.be.an.int
        size.should.equal 4

    it 'should return 3 for mission 4 with 6 or fewer players', ->
      sizes = [5..6].map (s) -> shared.teamSize s, 4

      sizes.map (size) ->
        size.should.be.an.int
        size.should.equal 3

    it 'should return 4 for mission 4 with 7 players', ->
      size = shared.teamSize 7, 4

      size.should.be.an.int
      size.should.equal 4

    it 'should return 5 for mission 4 with 8 or more players', ->
      sizes = [8..10].map (s) -> shared.teamSize s, 4

      sizes.map (size) ->
        size.should.be.an.int
        size.should.equal 5

    it 'should return 3 for mission 5 with 5 players', ->
      size = shared.teamSize 5, 5

      size.should.be.an.int
      size.should.equal 3

    it 'should return 4 for mission 5 with 6 or 7 players', ->
      sizes = [6, 7].map (s) -> shared.teamSize s, 5

      sizes.map (size) ->
        size.should.be.an.int
        size.should.equal 4

    it 'should return 5 for mission 5 with 8 or more players', ->
      sizes = [8..10].map (s) -> shared.teamSize s, 5

      sizes.map (size) ->
        size.should.be.an.int
        size.should.equal 5

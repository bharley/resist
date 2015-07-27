should = require('chai').should()
utils  = require '../../src/server/utils.coffee'

describe 'Array', ->
  describe '#findBy()', ->
    it 'should be a function in the Array prototype', ->
      Array.prototype.findBy.should.be.a.function

    it 'should return the index of a matching object', ->
      match = [
        {name: 'Fred'}
        {name: 'Wilma'}
        {name: 'Ted'}
      ].findBy (p) -> p.name is 'Wilma'

      match.should.be.an.int
      match.should.equal 1

    it 'should return the index of the first matching object', ->
      match = [
        {type: 'spoon', owner: 'Fred'}
        {type: 'fork',  owner: 'Dan'} # Fuck Dan
        {type: 'plate', owner: 'Susan'}
        {type: 'spork', owner: 'Fred'}
      ].findBy (d) -> d.owner is 'Fred'

      match.should.be.an.int
      match.should.equal 0

    it 'should ignore non-object members', ->
      match = [
        {color: 'red'}
        {color: 'green'}
        'blue'
        {color: 'orange'}
      ].findBy (t) -> t.color is 'orange'

      match.should.be.an.int
      match.should.equal 3

    it 'should return `false` when there are no matches', ->
      match = [
        {sku: '9001', price: 0.99}
        {sku: '9002', price: 0.49}
        {sku: '9003', price: 3.98}
      ].findBy (p) -> p.sku is '9000'

      match.should.be.false

    it 'should work on an empty array', ->
      match = [].findBy (t) -> t.price is 3.99

      match.should.be.false

describe 'String', ->
  describe '#padLeft()', ->
    it 'should be a function in the String prototype', ->
      String.prototype.padLeft.should.be.a.function

    it 'should not pad if the string already meets the length', ->
      output = 'taco'.padLeft 4

      output.should.be.a.string
      output.should.equal 'taco'

    it 'should not pad if the string exceeds the length', ->
      output = 'pizza'.padLeft 2

      output.should.be.a.string
      output.should.equal 'pizza'

    it 'should add spaces to the left of a string under the length', ->
      output = 'burrito'.padLeft 9

      output.should.be.a.string
      output.should.equal '  burrito'

    it 'should add spaces to the left of an empty string', ->
      output = ''.padLeft 2

      output.should.be.a.string
      output.should.equal '  '

    it 'should add the given character to the left of a string under the length', ->
      output = 'hamburger'.padLeft 20, '$'

      output.should.be.a.string
      output.should.equal '$$$$$$$$$$$hamburger'


  describe '#uppercaseWords()', ->
    it 'should be a function in the String prototype', ->
      String.prototype.uppercaseWords.should.be.a.function

    it 'should work on an empty string', ->
      output = ''.uppercaseWords()

      output.should.be.a.string
      output.should.equal ''

    it 'should work on a string of spaces', ->
      output = '  '.uppercaseWords()

      output.should.be.a.string
      output.should.equal '  '

    it 'should work on a string without words', ->
      output = '@12'.uppercaseWords()

      output.should.be.a.string
      output.should.equal '@12'

    it 'should work on a single letter', ->
      output = 'a'.uppercaseWords()

      output.should.be.a.string
      output.should.equal 'A'

    it 'should capitalize the first letter of a single word', ->
      input = 'foo'
      output = input.uppercaseWords()

      output.should.be.a.string
      output.should.equal 'Foo'

    it 'should capitalize the first letter of every word in a string', ->
      input = 'this is sausage'
      output = input.uppercaseWords()

      output.should.be.a.string
      output.should.equal 'This Is Sausage'

    it 'should not capitalize segments after a hyphen in a hyphenated word', ->
      input = 'one-hundred and twenty dollars'
      output = input.uppercaseWords()

      output.should.be.a.string
      output.should.equal 'One-hundred And Twenty Dollars'

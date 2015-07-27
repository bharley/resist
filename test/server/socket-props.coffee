should      = require('chai').should()
SocketProps = require '../../src/server/socket-props.coffee'

describe 'SocketProps', ->
  describe '#props()', ->
    it 'should be a prototype of SocketProps', ->
      SocketProps.prototype.props.should.be.a.function

    it 'should not include itself in the output', ->
      props = (new SocketProps).props()

      props.should.be.an.object
      props.should.be.empty

    it 'should not include functions in the output', ->
      s = new SocketProps
      s.test = -> 'test'
      props = s.props()

      props.should.be.an.object
      props.should.be.empty

    it 'should include other properties in the output', ->
      s = new SocketProps
      s.test = 'test'
      props = s.props()

      props.should.be.an.object
      props.should.eql {test: 'test'}

    it 'should not include properties beginning with an underscore in the output', ->
      s = new SocketProps
      s._test = 'test'
      s.test = 'test'
      s.another_test = 'test'
      props = s.props()

      props.should.be.an.object
      props.should.eql {test: 'test', another_test: 'test'}

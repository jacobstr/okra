okra = require '../index'
Watcher = require '../lib/Watcher'
WatcherCollection = require '../lib/WatcherCollection'

{ Node, GroupNode, Tag } = tags = require '../lib/tags'


class StringLogger
  constructor: ->
    @messages = []
  log: (args...) ->
    @messages = @messages.concat args...
  reset: ->
    @messages = []

stringlogger = new StringLogger
okra = okra.logger stringlogger

describe 'okra', ->
  beforeEach ->
    stringlogger.reset()

  it 'should have working flag attributes', ->
    okra.color.banner.dump 'A string encased in a banner.'
    okra.color.dump 'A simple string'
    okra.notrace.fns.dump 'multiple', 'arguments', 'no trace hint', okra.depth
    stringlogger.messages.should.have.length 3

  it 'should have working and fluent setter methods', ->
    okra.width(50).interval(100).notrace.dump 'helloo'
    stringlogger.messages.should.have.length 1

  it 'should support debug depth', ->
    console.log "messages", stringlogger.messages
    okra.nocolor.dump 'hello'
    line = okra.here.line
    expected = new RegExp "^test.coffee: \<anon\> \\(#{line-1}\\)"
    stringlogger.messages.should.have.length 1
    stringlogger.messages[0].should.match expected

  describe 'Tags', ->
    describe 'Filter parsing', ->
      it 'should parse a tag', ->
        group = tags.parse 'hello'
        group.should.be.an.instanceOf GroupNode
        group.nodes[0].tag.should.eql 'hello'
        group.nodes[0].predicate.should.eql 'all'

      it 'should parse a list of tags', ->
        group = tags.parse 'hello world'
        group.nodes[0].tag.should.eql 'hello'
        group.nodes[1].tag.should.eql 'world'

      it 'should parse a negated tag', ->
        group = tags.parse '!hello'
        group.nodes[0].tag.should.eql 'hello'
        group.nodes[0].predicate.should.eql 'not'

      it 'should parse a group', ->
        group = tags.parse '[good morning]'
        group.nodes[0].group.nodes[0].tag.should.eql 'good'
        group.nodes[0].group.nodes[1].tag.should.eql 'morning'
        group.nodes[0].predicate.should.eql 'all'

      it 'should parse a tag + group', ->
        group = tags.parse 'tag [good morning]'
        group.nodes[0].tag.should.eql 'tag'
        group.nodes[1].group.nodes[0].tag.should.eql 'good'
        group.nodes[1].group.nodes[1].tag.should.eql 'morning'

      it 'should parse a tag* + group', ->
        group = tags.parse 'tag tag2 tag3 [good morning]'
        group.nodes[0].tag.should.eql 'tag'
        group.nodes[1].tag.should.eql 'tag2'
        group.nodes[2].tag.should.eql 'tag3'
        group.nodes[3].group.nodes[0].tag.should.eql 'good'
        group.nodes[3].group.nodes[1].tag.should.eql 'morning'

      it 'should parse a group + tag', ->
        group = tags.parse '[good morning] tag'
        group.nodes[0].group.nodes[0].tag.should.eql 'good'
        group.nodes[0].group.nodes[1].tag.should.eql 'morning'
        group.nodes[1].tag.should.eql 'tag'

      it 'should parse a group + tag tag2 tag3', ->
        group = tags.parse '[good morning] tag tag2 tag3'
        group.nodes[0].group.nodes[0].tag.should.eql 'good'
        group.nodes[0].group.nodes[1].tag.should.eql 'morning'
        group.nodes[1].tag.should.eql 'tag'
        group.nodes[2].tag.should.eql 'tag2'
        group.nodes[3].tag.should.eql 'tag3'

      it 'should parse a tag + group + tag', ->
        group = tags.parse 'tag [good morning] tag'

      it 'should parse ~[hello ![world] people]', ->
        group = tags.parse '~[hello ![world] people]'

      it 'should parse a convoluted expression', ->
        group = tags.parse '[production] ![~[warn debug] info] !tag tag'

    describe "Filter Execution", ->
      auth_event = "auth info login authorizer development"
      payment_event = "payment info gateway production"
      database_crash = "critical mongo database production"
      database_crash_devel = "critical mongo database development"

      events = [auth_event, payment_event, database_crash, database_crash_devel]
      filter = (node) ->
        (event for event in events when node.evaluate event)

      it 'should filter simple inclusive patterns: info', ->
        node = tags.parse 'info'
        filter(node).should.eql [ auth_event, payment_event ]

      it 'should filter by a simple negation: !payment', ->
        node = tags.parse '!payment'
        filter(node).should.eql [ auth_event, database_crash, database_crash_devel ]

      it 'should filter by double negation: ![!payment]', ->
        node = tags.parse '![!payment]'
        filter(node).should.eql [ payment_event ]

      it 'should filter by some: ~[[production payment] [development critical]]', ->
        node = tags.parse '~[[production payment] [development critical]]'
        filter(node).should.eql [ payment_event, database_crash_devel ]

  describe 'Watchers', ->

    watcher_collection = null

    beforeEach ->
      watcher_collection = new WatcherCollection()
      watcher_collection.add new Watcher(sinon.spy, interval_ms:10, 'debug mongo')
      watcher_collection.add new Watcher(sinon.spy, interval_ms:10, 'debug auth')
      watcher_collection.add new Watcher(sinon.spy, interval_ms:10, 'info auth')

    it 'should add watchers', ->
      watcher_collection.watchers.should.have.length 3

    it 'should filter watchers by a simple tag', ->
      watcher_collection.filter('info').watchers.should.have.length 1

    it 'should filter watchers by a complex tag expression', ->
      watcher_collection.filter('~[debug auth] !mongo').watchers.should.have.length 2

  describe 'okra Watching', ->
    it 'should watch periodically', (done) ->
      obj = counter:1

      okra.banner.interval(50).watch 'integer', ->
        console.log "triggered"
        obj.counter += 1

      setTimeout ->
        obj.counter.should.eql 3
        okra.watch('integer').stop()
        done()
      , (50*3)


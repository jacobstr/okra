class Watcher
  # @param interval - ms
  # @param tag_spec - dot delimited, space separated tags.
  #                   multiple tags may be space separated.
  #
  # @see WatcherCollection.filter to see the tag filtering syntax.
  constructor: (@fn, @options, @tag_spec) ->
    @tag_spec = @tag_spec.toLowerCase()
    @invocations = 0

  start: ->
    fn = =>
      @invocations++
      @fn()

      if @options.times and @invocations > @options.times
        @options.finally?()
        @stop()

    if @interval
      clearInterval @interval

    @interval = setInterval fn, @options.interval_ms

    @

  filter: (group_node) ->
    group_node.evaluate @tag_spec

  stop: ->
    clearInterval @interval
    @interval = null

    @

module.exports = Watcher

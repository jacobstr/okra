tags = require './tags.coffee'

class WatcherCollection
  constructor: (@watchers = []) ->

  start: ->
    watcher.stop() for watcher in @watchers
    watcher.start() for watcher in @watchers

    @

  stop: ->
    watcher.stop() for watcher in @watchers

    @

  # Filters according to a tag expressions. See the Tags tests for details of
  # their syntax.
  filter: (tag_expression) ->

    group_node = tags.parse tag_expression

    new WatcherCollection (
      watcher for watcher in @watchers when watcher.filter group_node
    )

  add: (watcher) ->
    @watchers ||= []
    @watchers.push watcher

module.exports = WatcherCollection

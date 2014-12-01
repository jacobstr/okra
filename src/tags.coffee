peg = require 'pegjs'
util = require 'util'
fs = require 'fs'

parser = require './tagparser'

class GroupNode
  constructor: (@nodes) ->

  evaluate: (tag_string) ->
    @nodes.every (current) -> current.evaluate(tag_string)

class Node
  constructor: (@group, @predicate) ->

  evaluate: (tag_string) ->
    switch @predicate
      when 'all'
        @group.nodes.every (current) -> current.evaluate(tag_string)
      when 'not'
        not @group.nodes.every (current) -> current.evaluate(tag_string)
      when 'some'
        @group.nodes.some (current) -> current.evaluate(tag_string)
      else
        @group.nodes.every (current) -> current.evaluate(tag_string)

class Tag
  constructor: (@tag, @predicate) ->

  @split: (tag_string) ->
    tag_string.trim().replace(/[ ]+}/, ' ').split(' ')

  evaluate: (tag_string) ->
    intermediate = @tag in @constructor.split(tag_string)
    switch @predicate
      when 'not'
        ! intermediate
      else
        intermediate

class UniversalTag extends Tag

class ExpressionNode extends Node
  constructor: (@predicate) ->

class Predicate
  PREDICATES = every: '^', not: '!', some: '~'

  constructor:(type) ->
    if type in Object.keys(PREDICATES)
      @type = PREDICATES[type]
    else
      @type = PREDICATES[type]

module.exports =
  parse: (key_filter) ->
    parser.parse key_filter
  match: (key_filter) ->
    true
  UniversalTag: UniversalTag
  Tag: Tag
  ExpressionNode: ExpressionNode
  Node: Node
  GroupNode: GroupNode

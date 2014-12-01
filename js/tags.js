(function() {
  var ExpressionNode, GroupNode, Node, Predicate, Tag, UniversalTag, fs, parser, peg, util,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  peg = require('pegjs');

  util = require('util');

  fs = require('fs');

  parser = require('./tagparser');

  GroupNode = (function() {
    function GroupNode(nodes) {
      this.nodes = nodes;
    }

    GroupNode.prototype.evaluate = function(tag_string) {
      return this.nodes.every(function(current) {
        return current.evaluate(tag_string);
      });
    };

    return GroupNode;

  })();

  Node = (function() {
    function Node(group, predicate) {
      this.group = group;
      this.predicate = predicate;
    }

    Node.prototype.evaluate = function(tag_string) {
      switch (this.predicate) {
        case 'all':
          return this.group.nodes.every(function(current) {
            return current.evaluate(tag_string);
          });
        case 'not':
          return !this.group.nodes.every(function(current) {
            return current.evaluate(tag_string);
          });
        case 'some':
          return this.group.nodes.some(function(current) {
            return current.evaluate(tag_string);
          });
        default:
          return this.group.nodes.every(function(current) {
            return current.evaluate(tag_string);
          });
      }
    };

    return Node;

  })();

  Tag = (function() {
    function Tag(tag, predicate) {
      this.tag = tag;
      this.predicate = predicate;
    }

    Tag.split = function(tag_string) {
      return tag_string.trim().replace(/[ ]+}/, ' ').split(' ');
    };

    Tag.prototype.evaluate = function(tag_string) {
      var intermediate, _ref;
      intermediate = (_ref = this.tag, __indexOf.call(this.constructor.split(tag_string), _ref) >= 0);
      switch (this.predicate) {
        case 'not':
          return !intermediate;
        default:
          return intermediate;
      }
    };

    return Tag;

  })();

  UniversalTag = (function(_super) {
    __extends(UniversalTag, _super);

    function UniversalTag() {
      return UniversalTag.__super__.constructor.apply(this, arguments);
    }

    return UniversalTag;

  })(Tag);

  ExpressionNode = (function(_super) {
    __extends(ExpressionNode, _super);

    function ExpressionNode(predicate) {
      this.predicate = predicate;
    }

    return ExpressionNode;

  })(Node);

  Predicate = (function() {
    var PREDICATES;

    PREDICATES = {
      every: '^',
      not: '!',
      some: '~'
    };

    function Predicate(type) {
      if (__indexOf.call(Object.keys(PREDICATES), type) >= 0) {
        this.type = PREDICATES[type];
      } else {
        this.type = PREDICATES[type];
      }
    }

    return Predicate;

  })();

  module.exports = {
    parse: function(key_filter) {
      return parser.parse(key_filter);
    },
    match: function(key_filter) {
      return true;
    },
    UniversalTag: UniversalTag,
    Tag: Tag,
    ExpressionNode: ExpressionNode,
    Node: Node,
    GroupNode: GroupNode
  };

}).call(this);

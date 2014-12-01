{
  // For whatever reason, __dirname refers to our node_modules/peg/lib folder.
  okra = require(__dirname+"/../index")
  ast = require(__dirname+"/tags")
  Tag = ast.Tag
  ExpressionNode = ast.ExpressionNode
  Node = ast.Node
  GroupNode = ast.GroupNode
}

Start
  = Node

Node
  = nodes:Group* { return new GroupNode(nodes) }

Group
  = _ pred:Predicate "[" node:(Node) "]" _ { return new Node(node, pred) }
  / Tag

Tag
  = _ predicate:Predicate tag:([a-z0-9]+) _ { return new Tag(tag.join(""), predicate) }

Predicate
  = (TokenNot / TokenSome / TokenAll )
  /  { return 'all' }

TokenAll
  = '^' { return 'all' }

TokenNot
  = '!' { return 'not' }

TokenSome
  = '~' { return 'some' }
_
  "single space"
  = " "?

__
  "many spaces"
  = [ ]*

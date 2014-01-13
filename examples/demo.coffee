okra = require '../'

# Dumping string within named functions generates succinct stack traces.
example = ->
  okra.dump 'within a function'
  nested_example = ->
    okra.dump 'and again to see the default stack depth'
  nested_example()
example()

# Dumping a function with function stringification enabled.
okra.fns.dump example

# Saved presets...
okra.color.banner.save 'fancy'

# Become available as correpsondingly named fluent attributes.
okra.fancy.dump 'Using a previously saved preset and banner mode for more visible output'

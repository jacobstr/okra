Okra
====

Okra is a tracing module for node. It's for those times when print statements
are your most effective debugging tool.

Advantages over console.log:

  1. Messages automatically include a short stack trace so you know where they came
     from.
  2. A fluent API to configure display options with the ability to save presets.
  3. A banner mode (for messages you want to be especially prominent in the midst of console spam)
  4. Function stringification flags when you want to see the body of a function
     instead of [Function] when dumping an object.
  5. A watch mode for periodically watching a variable.

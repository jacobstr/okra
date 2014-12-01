require 'colors'
util = require 'util'
path = require 'path'
require 'coffee-errors'
stackTrace = require 'stack-trace'
extend = util._extend
inspector = require('eyes').inspector stream:null

Watcher = require './Watcher'
WatcherCollection = require './WatcherCollection'

all_watchers = new WatcherCollection

class StackTrace
  constructor: (@message)->
    @name = 'StackTrace'

inspect = (arg) ->
  inspector(arg)

# Blacklist internal stack traces
is_filtered = (item) ->
  files = (path.join(path.dirname(__dirname), file) for file in [
    'src/Okra.coffee'
    'index.coffee'
    'js/Okra.js'
    'index.js'
  ])

  item.fileName in files

# Uses coffee-errors and stack-trace together to generate strucured backtrace
# data (filenames, line numbers) in an object instead of a string I'd have to
# parse. Feh!
parsed_trace = (options, below_fn) ->
  trace = coffee_trace options, below_fn
  for item in stackTrace.parse trace when not is_filtered item
    line: item.lineNumber
    filename: item.fileName
    basename: path.basename item.fileName
    func: item.functionName or item.methodName or '<anon>'

# Wraps up a goofy javascript idiom for generating stacktraces.
coffee_trace = (options, below_fn) ->
  below_fn ?= coffee_trace
  result = new StackTrace ''
  Error.captureStackTrace result, below_fn
  result

class Okra
  @::presets = {}

  constructor: (options = {})->
    @options =
      # Banner settings
      banner:
        width: 77
        enabled: false
        vspace: 1
      # Convert functions to their strings.
      fnstrings: false
      # util.inspect options
      inspect:
        depth: 3
        showHidden: false
        color: true
      # Whether to prefix with short trace.
      trace:
        enabled: true
        depth: 2
        offset: 0
      watch:
        functions: []
        interval_ms: 2000
      logger:
        console

    @options = extend @options, options

  herefn = ->
      parsed_trace({}, herefn)[0]

  # Dumps our current location in the code
  Object.defineProperty @::, "here",
    get: herefn

  # Disable backtrace debug prefixes for dumped messages.
  Object.defineProperty @::, "notrace",
    get: ->
      @options.trace.enabled = false
      @

  # Alias for notrace
  Object.defineProperty @::, "nt",
    get: ->
      @notrace

  # Banners wrap output in a noticeable block of output. Useful when you're
  # dumping a lot of debug output.
  Object.defineProperty @::, "banner",
    get: ->
      @options.banner.enabled = true
      @

  # Sets the width of ascii banners
  width: (width) ->
    @options.banner.width = width
    @

  # Enable colorization
  Object.defineProperty @::, "color",
    get: ->
      @options.inspect.color = true
      @

  # Disable colorization
  Object.defineProperty @::, "nocolor",
    get: ->
      @options.inspect.color = false
      @

  # Widen the banner by 50%
  Object.defineProperty @::, "widen",
    get: ->
      @options.banner.width = Math.ceil @options.banner.width * 1.5
      @

  # Broaden the vspace between banners. Enables banners by default.
  Object.defineProperty @::, "broaden",
    get: ->
      @options.banner.enabled = true
      @options.banner.vspace = Math.ceil @options.banner.vspace * 1.5

  # Deepen object inspection depth
  Object.defineProperty @::, "deeper",
    get: ->
      @options.inspect.depth = Math.ceil @options.inspect.depth * 1.5
      @

  # Stringify function names
  Object.defineProperty @::, "fns",
    get: ->
      @options.fnstring = true
      @

  # Sets the inspection depth for object dumps.
  depth: (depth) ->
    @options.inspect.depth = depth
    @

  # Skip the first offset elements ouf generated stack traces.
  offset: (offset) ->
    @options.trace.offset = offset
    @

  # Sets the depth of our stack trace.
  td: (trace_depth) ->
    @options.trace.depth = trace_depth
    @

  # Sets the basis point for stack traces.
  below: (below_fn) ->
    @options.trace.belowFn = below_fn
    @

  # How long of an interval to use between watch invocations.
  interval: (interval_ms) ->
    @options.watch.interval_ms = interval_ms
    @

  # How many times to trigger the watcher, unlimited by default.
  # An optional function `fin` may be called at the end.
  times: (times, fin = ->) ->
    @options.watch.times = times
    @options.watch.finally = fin
    @

  # Set the output module. Should implement a `log` method accepting multiple
  # arguments
  logger: (logger) ->
    @options.logger = logger
    @

  # Generalized output method. Private.
  output: (args...) ->
    messages = (
      for arg in args
        if (@options.inspect.color == false) and arg?.stripColors
          arg.stripColors
        else
          arg
    )
    @options.logger.log messages...

  # Save this okra coniguration as a preset.
  #
  # For example:
  #     okra.td(5).banner.color.save 'fancy'
  #     okra.fancy.dump 'hello'
  save: (name) ->
    # Lazily avoids a cyclic dependency.
    proxy = require '../'

    @constructor::presets[name] = preset = @options

    # Create a property corresponding to the preset name.
    Object.defineProperty @constructor::, name,
      get: ->
        @options = extend @options, preset
        @

    # Update the exposed proxy as well.
    Object.defineProperty proxy, name,
      get: ->
        okra = new Okra()
        okra[name]
    @

  # Conduct an object dump utilizing our current configuration.
  dump: (args...) ->
    formatted = []
    for arg in args
      if typeof arg == 'string'
        formatted.push arg.green
      else if arg instanceof Number
        # If console.log encounters strings/numbers it starts to escape newlines
        # which is generally ugly. So we convert them to strings.
        formatted.push "#{arg}".blue
      else if arg instanceof Function
        if @options.fnstring
          formatted.push renderfunction arg.toString()
        else
          formatted.push inspect(arg)
      else if typeof arg == 'object'
        formatted.push arg.constructor.name.magenta
        formatted.push inspect(arg)
      else
        formatted.push util.inspect arg, @options.inspect

    unless @options.traces
      traces = parsed_trace(@options, (@options.trace.belowFn or @dump))
    else
      traces = @options.traces
    parsed_traces = for trace in traces[@options.trace.offset...@options.trace.offset+@options.trace.depth]
      "#{trace.basename}: #{trace.func.yellow}" + " (#{trace.line})".cyan

    # Bold the topmost trace.
    if parsed_traces[0]? then parsed_traces[0] = parsed_traces[0].bold
    joined_trace = parsed_traces.join(" « ")

    # Generates an ascii banner around the dump message.
    if @options.banner.enabled
      width = @options.banner.width
      banner = joined_trace
      length = banner.stripColors.length
      if length < width
        banner += Array(width-length).join("#").cyan

      message = []
      message.push Array(@options.banner.vspace).join("\n")
      message.push banner
      message.push "\n"
      message.push formatted.join("\n")
      message.push "\n"
      message.push Array(width).join("#").green
      message.push Array(@options.banner.vspace).join("\n")

      @output message.join("")
    else
      if @options.trace.enabled
        @output [joined_trace, " « "].concat(formatted).join("")
      else
        @output formatted.join("")

  # Output a stack trace.
  trace: ->
    unless @options.traces
      trace = coffee_trace(@options, @options.belowFn or @trace)
      @dump [trace.stack]
    else
      @dump @options.traces

  # If two arguments are provided, we set a new watcher.
  # With a single arg, we expose a watcher-specific api that operates on
  # a collection of watchers filtered with the provided key.
  watch: ->
    switch arguments.length
      when 2
        [tags, arg] = arguments

        # Set the stack trace now, otherwise we get a useless trace from
        # timers.js _onTimeout
        traces = parsed_trace(@options, (@options.trace.belowFn or @watch))
        okra = new Okra(extend(traces: traces, @options))
        cb = =>
          if typeof arg == 'function'
            okra.dump arg()
          else
            okra.dump arg

        watcher = new Watcher cb, @options.watch, tags
        all_watchers.add watcher
        watcher.start()

        @
      when 1
        [tag_expression] = arguments
        all_watchers.filter tag_expression

shrinkpath = (path) ->
  # Elements are assigned by:
  # 1. Left to right.
  # 2. Splats last.
  [start..., dir, fname] = path.split('/')
  [start, mid...] = start
  if mid.length
    mid = '...'
  [start,mid,dir,fname].join '/'

# Used to output functions when the fnstrings option is enabled.
renderfunction = (fnstring) ->
  fnstring.replace /function/, '->'
  parts = fnstring.split('')
  if parts.length > 200
    parts = parts[0...100].concat(['...']).concat parts[-100...]
  parts.join('')

module.exports = Okra

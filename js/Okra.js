(function() {
  var Okra, StackTrace, Watcher, WatcherCollection, all_watchers, coffee_trace, extend, inspect, inspector, is_filtered, parsed_trace, path, renderfunction, shrinkpath, stackTrace, util,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __slice = [].slice;

  require('colors');

  util = require('util');

  path = require('path');

  require('coffee-errors');

  stackTrace = require('stack-trace');

  extend = util._extend;

  inspector = require('eyes').inspector({
    stream: null
  });

  Watcher = require('./Watcher');

  WatcherCollection = require('./WatcherCollection');

  all_watchers = new WatcherCollection;

  StackTrace = (function() {
    function StackTrace(message) {
      this.message = message;
      this.name = 'StackTrace';
    }

    return StackTrace;

  })();

  inspect = function(arg) {
    return inspector(arg);
  };

  is_filtered = function(item) {
    var file, files, _ref;
    files = (function() {
      var _i, _len, _ref, _results;
      _ref = ['src/Okra.coffee', 'index.coffee', 'js/Okra.js', 'index.js'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        file = _ref[_i];
        _results.push(path.join(path.dirname(__dirname), file));
      }
      return _results;
    })();
    return _ref = item.fileName, __indexOf.call(files, _ref) >= 0;
  };

  parsed_trace = function(options, below_fn) {
    var item, trace, _i, _len, _ref, _results;
    trace = coffee_trace(options, below_fn);
    _ref = stackTrace.parse(trace);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (!is_filtered(item)) {
        _results.push({
          line: item.lineNumber,
          filename: item.fileName,
          basename: path.basename(item.fileName),
          func: item.functionName || item.methodName || '<anon>'
        });
      }
    }
    return _results;
  };

  coffee_trace = function(options, below_fn) {
    var result;
    if (below_fn == null) {
      below_fn = coffee_trace;
    }
    result = new StackTrace('');
    Error.captureStackTrace(result, below_fn);
    return result;
  };

  Okra = (function() {
    var herefn;

    Okra.prototype.presets = {};

    function Okra(options) {
      if (options == null) {
        options = {};
      }
      this.options = {
        banner: {
          width: 77,
          enabled: false,
          vspace: 1
        },
        fnstrings: false,
        inspect: {
          depth: 3,
          showHidden: false,
          color: true
        },
        trace: {
          enabled: true,
          depth: 2,
          offset: 0
        },
        watch: {
          functions: [],
          interval_ms: 2000
        },
        logger: console
      };
      this.options = extend(this.options, options);
    }

    herefn = function() {
      return parsed_trace({}, herefn)[0];
    };

    Object.defineProperty(Okra.prototype, "here", {
      get: herefn
    });

    Object.defineProperty(Okra.prototype, "notrace", {
      get: function() {
        this.options.trace.enabled = false;
        return this;
      }
    });

    Object.defineProperty(Okra.prototype, "nt", {
      get: function() {
        return this.notrace;
      }
    });

    Object.defineProperty(Okra.prototype, "banner", {
      get: function() {
        this.options.banner.enabled = true;
        return this;
      }
    });

    Okra.prototype.width = function(width) {
      this.options.banner.width = width;
      return this;
    };

    Object.defineProperty(Okra.prototype, "color", {
      get: function() {
        this.options.inspect.color = true;
        return this;
      }
    });

    Object.defineProperty(Okra.prototype, "nocolor", {
      get: function() {
        this.options.inspect.color = false;
        return this;
      }
    });

    Object.defineProperty(Okra.prototype, "widen", {
      get: function() {
        this.options.banner.width = Math.ceil(this.options.banner.width * 1.5);
        return this;
      }
    });

    Object.defineProperty(Okra.prototype, "broaden", {
      get: function() {
        this.options.banner.enabled = true;
        return this.options.banner.vspace = Math.ceil(this.options.banner.vspace * 1.5);
      }
    });

    Object.defineProperty(Okra.prototype, "deeper", {
      get: function() {
        this.options.inspect.depth = Math.ceil(this.options.inspect.depth * 1.5);
        return this;
      }
    });

    Object.defineProperty(Okra.prototype, "fns", {
      get: function() {
        this.options.fnstring = true;
        return this;
      }
    });

    Okra.prototype.depth = function(depth) {
      this.options.inspect.depth = depth;
      return this;
    };

    Okra.prototype.offset = function(offset) {
      this.options.trace.offset = offset;
      return this;
    };

    Okra.prototype.td = function(trace_depth) {
      this.options.trace.depth = trace_depth;
      return this;
    };

    Okra.prototype.below = function(below_fn) {
      this.options.trace.belowFn = below_fn;
      return this;
    };

    Okra.prototype.interval = function(interval_ms) {
      this.options.watch.interval_ms = interval_ms;
      return this;
    };

    Okra.prototype.times = function(times, fin) {
      if (fin == null) {
        fin = function() {};
      }
      this.options.watch.times = times;
      this.options.watch["finally"] = fin;
      return this;
    };

    Okra.prototype.logger = function(logger) {
      this.options.logger = logger;
      return this;
    };

    Okra.prototype.output = function() {
      var arg, args, messages, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      messages = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = args.length; _i < _len; _i++) {
          arg = args[_i];
          if ((this.options.inspect.color === false) && (arg != null ? arg.stripColors : void 0)) {
            _results.push(arg.stripColors);
          } else {
            _results.push(arg);
          }
        }
        return _results;
      }).call(this);
      return (_ref = this.options.logger).log.apply(_ref, messages);
    };

    Okra.prototype.save = function(name) {
      var preset, proxy;
      proxy = require('../');
      this.constructor.prototype.presets[name] = preset = this.options;
      Object.defineProperty(this.constructor.prototype, name, {
        get: function() {
          this.options = extend(this.options, preset);
          return this;
        }
      });
      Object.defineProperty(proxy, name, {
        get: function() {
          var okra;
          okra = new Okra();
          return okra[name];
        }
      });
      return this;
    };

    Okra.prototype.dump = function() {
      var arg, args, banner, formatted, joined_trace, length, message, parsed_traces, trace, traces, width, _i, _len;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      formatted = [];
      for (_i = 0, _len = args.length; _i < _len; _i++) {
        arg = args[_i];
        if (typeof arg === 'string') {
          formatted.push(arg.green);
        } else if (arg instanceof Number) {
          formatted.push(("" + arg).blue);
        } else if (arg instanceof Function) {
          if (this.options.fnstring) {
            formatted.push(renderfunction(arg.toString()));
          } else {
            formatted.push(inspect(arg));
          }
        } else if (typeof arg === 'object') {
          formatted.push(arg.constructor.name.magenta);
          formatted.push(inspect(arg));
        } else {
          formatted.push(util.inspect(arg, this.options.inspect));
        }
      }
      if (!this.options.traces) {
        traces = parsed_trace(this.options, this.options.trace.belowFn || this.dump);
      } else {
        traces = this.options.traces;
      }
      parsed_traces = (function() {
        var _j, _len1, _ref, _results;
        _ref = traces.slice(this.options.trace.offset, this.options.trace.offset + this.options.trace.depth);
        _results = [];
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          trace = _ref[_j];
          _results.push(("" + trace.basename + ": " + trace.func.yellow) + (" (" + trace.line + ")").cyan);
        }
        return _results;
      }).call(this);
      if (parsed_traces[0] != null) {
        parsed_traces[0] = parsed_traces[0].bold;
      }
      joined_trace = parsed_traces.join(" « ");
      if (this.options.banner.enabled) {
        width = this.options.banner.width;
        banner = joined_trace;
        length = banner.stripColors.length;
        if (length < width) {
          banner += Array(width - length).join("#").cyan;
        }
        message = [];
        message.push(Array(this.options.banner.vspace).join("\n"));
        message.push(banner);
        message.push("\n");
        message.push(formatted.join("\n"));
        message.push("\n");
        message.push(Array(width).join("#").green);
        message.push(Array(this.options.banner.vspace).join("\n"));
        return this.output(message.join(""));
      } else {
        if (this.options.trace.enabled) {
          return this.output([joined_trace, " « "].concat(formatted).join(""));
        } else {
          return this.output(formatted.join(""));
        }
      }
    };

    Okra.prototype.trace = function() {
      var trace;
      if (!this.options.traces) {
        trace = coffee_trace(this.options, this.options.belowFn || this.trace);
        return this.dump([trace.stack]);
      } else {
        return this.dump(this.options.traces);
      }
    };

    Okra.prototype.watch = function() {
      var arg, cb, okra, tag_expression, tags, traces, watcher;
      switch (arguments.length) {
        case 2:
          tags = arguments[0], arg = arguments[1];
          traces = parsed_trace(this.options, this.options.trace.belowFn || this.watch);
          okra = new Okra(extend({
            traces: traces
          }, this.options));
          cb = (function(_this) {
            return function() {
              if (typeof arg === 'function') {
                return okra.dump(arg());
              } else {
                return okra.dump(arg);
              }
            };
          })(this);
          watcher = new Watcher(cb, this.options.watch, tags);
          all_watchers.add(watcher);
          watcher.start();
          return this;
        case 1:
          tag_expression = arguments[0];
          return all_watchers.filter(tag_expression);
      }
    };

    return Okra;

  })();

  shrinkpath = function(path) {
    var dir, fname, mid, start, _i, _ref, _ref1;
    _ref = path.split('/'), start = 3 <= _ref.length ? __slice.call(_ref, 0, _i = _ref.length - 2) : (_i = 0, []), dir = _ref[_i++], fname = _ref[_i++];
    _ref1 = start, start = _ref1[0], mid = 2 <= _ref1.length ? __slice.call(_ref1, 1) : [];
    if (mid.length) {
      mid = '...';
    }
    return [start, mid, dir, fname].join('/');
  };

  renderfunction = function(fnstring) {
    var parts;
    fnstring.replace(/function/, '->');
    parts = fnstring.split('');
    if (parts.length > 200) {
      parts = parts.slice(0, 100).concat(['...']).concat(parts.slice(-100));
    }
    return parts.join('');
  };

  module.exports = Okra;

}).call(this);

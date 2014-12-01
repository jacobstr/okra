(function() {
  var Watcher;

  Watcher = (function() {
    function Watcher(fn, options, tag_spec) {
      this.fn = fn;
      this.options = options;
      this.tag_spec = tag_spec;
      this.tag_spec = this.tag_spec.toLowerCase();
      this.invocations = 0;
    }

    Watcher.prototype.start = function() {
      var fn;
      fn = (function(_this) {
        return function() {
          var _base;
          _this.invocations++;
          _this.fn();
          if (_this.options.times && _this.invocations > _this.options.times) {
            if (typeof (_base = _this.options)["finally"] === "function") {
              _base["finally"]();
            }
            return _this.stop();
          }
        };
      })(this);
      if (this.interval) {
        clearInterval(this.interval);
      }
      this.interval = setInterval(fn, this.options.interval_ms);
      return this;
    };

    Watcher.prototype.filter = function(group_node) {
      return group_node.evaluate(this.tag_spec);
    };

    Watcher.prototype.stop = function() {
      clearInterval(this.interval);
      this.interval = null;
      return this;
    };

    return Watcher;

  })();

  module.exports = Watcher;

}).call(this);

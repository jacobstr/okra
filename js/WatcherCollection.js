(function() {
  var WatcherCollection, tags;

  tags = require('./tags');

  WatcherCollection = (function() {
    function WatcherCollection(watchers) {
      this.watchers = watchers != null ? watchers : [];
    }

    WatcherCollection.prototype.start = function() {
      var watcher, _i, _j, _len, _len1, _ref, _ref1;
      _ref = this.watchers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        watcher = _ref[_i];
        watcher.stop();
      }
      _ref1 = this.watchers;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        watcher = _ref1[_j];
        watcher.start();
      }
      return this;
    };

    WatcherCollection.prototype.stop = function() {
      var watcher, _i, _len, _ref;
      _ref = this.watchers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        watcher = _ref[_i];
        watcher.stop();
      }
      return this;
    };

    WatcherCollection.prototype.filter = function(tag_expression) {
      var group_node, watcher;
      group_node = tags.parse(tag_expression);
      return new WatcherCollection((function() {
        var _i, _len, _ref, _results;
        _ref = this.watchers;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          watcher = _ref[_i];
          if (watcher.filter(group_node)) {
            _results.push(watcher);
          }
        }
        return _results;
      }).call(this));
    };

    WatcherCollection.prototype.add = function(watcher) {
      this.watchers || (this.watchers = []);
      return this.watchers.push(watcher);
    };

    return WatcherCollection;

  })();

  module.exports = WatcherCollection;

}).call(this);

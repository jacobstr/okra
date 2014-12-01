(function () {
    var Okra, descriptor, excluded, prop, proxy, _fn, _i, _len, _ref, __slice = [].slice, __indexOf = [].indexOf || function (item) {
            for (var i = 0, l = this.length; i < l; i++) {
                if (i in this && this[i] === item)
                    return i;
            }
            return -1;
        };
    Okra = require('./js/Okra');
    proxy = {};
    excluded = ['constructor'];
    _ref = Object.getOwnPropertyNames(Okra.prototype);
    _fn = function (prop) {
        if (descriptor.value) {
            return proxy[prop] = function () {
                var args, okra;
                args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                okra = new Okra();
                return okra[prop].apply(okra, args);
            };
        } else {
            return Object.defineProperty(proxy, prop, {
                get: function () {
                    var okra;
                    okra = new Okra();
                    return okra[prop];
                }
            });
        }
    };
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        prop = _ref[_i];
        if (!(__indexOf.call(excluded, prop) < 0)) {
            continue;
        }
        descriptor = Object.getOwnPropertyDescriptor(Okra.prototype, prop);
        _fn(prop);
    }
    module.exports = proxy;
}.call(this));
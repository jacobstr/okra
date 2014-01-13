Okra = require './lib/Okra'

# I don't want api users having to do okra() or new Okra() but we want a new
# instance to be created when you start a chain off via the invocation/access
# of any of okra's methods/attributes
#
# The `proxy` object is what we actually export, it wraps the "true" implementation object
# in some magic methods so that we can start our fluent interface off without
# parenthesis.
#
# E.g. instead of:
#   okra().trace.dump 'Hello'
#
# We have:
#   okra.trace.dump 'Hello'
#
# Once the proxy method is called, we'll typically return a normal okra instance
# because the delegated-to methods are almost all fluent.
#
proxy = {}
excluded = ['constructor']

for prop in Object.getOwnPropertyNames(Okra::) when prop not in excluded
  descriptor = Object.getOwnPropertyDescriptor(Okra::, prop)

  do (prop) ->
    # A method descriptor will have value and writeable, a property descriptor
    # will not.
    if descriptor.value
        proxy[prop] = (args...) ->
          okra = new Okra()
          okra[prop].apply okra, args
    else
      Object.defineProperty proxy, prop,
        get: ->
          okra = new Okra()
          okra[prop]

module.exports = proxy

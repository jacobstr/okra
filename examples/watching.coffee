okra = require '../'

counter = value: 0
interval = setInterval ->
  counter.value++
, 10

okra.interval(7).times(5, -> clearInterval interval).watch 'counter', counter


async = require 'async'
loglet = require 'loglet'

class Funclet
  @make: () ->
    new Funclet() 
  constructor: () ->
    @calls = []
    @onError = console.error 
    @
  bind: (proc, args...) ->
    @then (next) ->
      proc args..., next
  then: (proc) ->
    @calls.push (arg ..., cb) ->
      try 
        proc arg..., cb
      catch e 
        cb e
    @
  map: (ary, proc) ->
    @then (next) ->
      async.map ary, proc, next
  thenMap: (proc) -> # expects the previous function to return an array.
    @then (ary, next) ->
      async.map ary, proc, next
  mapSeries: (ary, proc) ->
    @then (next) ->
      async.mapSeries ary, proc, next
  thenMapSeries: (proc) ->
    @then (ary, next) ->
      async.mapSeries ary, proc, next
  each: (ary, proc) ->
    @then (next) ->
      async.each ary, proc, next
  thenEach: (proc) -> # expects the previous function to return an array.
    @then (ary, next) ->
      async.each ary, proc, next
  eachSeries: (ary, proc) ->
    @then (next) ->
      async.eachSeries ary, proc, next
  thenEachSeries: (proc) ->
    @then (ary, next) ->
      async.eachSeries ary, proc, next
  parallel: (tasks) ->
    @then (next) ->
      async.parallel tasks, next
  thenParallel: () ->
    @then (tasks, next) ->
      async.parallel tasks, next
  catch: (@onError) ->
    @
  done: (lastCB = () ->) ->
    self = @
    interim = []
    helper = (func, next) ->
      cb = (err, res...) ->
          loglet.debug 'funclet.done.helper.cb', err, res
          if err 
            next err
          else 
            interim = res 
            next null 
      try 
        loglet.debug 'funclet.done.helper', interim..., cb
        func interim..., cb
        #func.apply self, args
      catch e 
        cb e
    async.eachSeries @calls, helper, (err) ->
      try 
        if err 
          self.onError err 
        else
          try 
            lastCB interim...
          catch e2 
            self.onError e2
      catch e
        self.onError e
    @

bind = (func, args...) ->
  Funclet.make().then (next) ->
    func args..., next

start = (func) ->
  Funclet.make().then func

map = (ary, proc) ->
  Funclet.make().map ary, proc

mapSeries = (ary, proc) ->
  Funclet.make().mapSeries ary, proc

each = (ary, proc) ->
  Funclet.make().each ary, proc

eachSeries = (ary, proc) ->
  Funclet.make().eachSeries ary, proc

parallel = (tasks) ->
  Funclet.make().parallel(tasks)

module.exports = 
  start: start
  bind: bind
  map: map
  mapSeries: mapSeries
  each: each
  eachSeries: eachSeries
  parallel: parallel


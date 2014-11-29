
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
  each: (ary, proc) ->
    @then (next) ->
      async.each ary, proc, next
  thenEach: (proc) -> # expects the previous function to return an array.
    @then (ary, next) ->
      async.each ary, proc, next
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

each = (ary, proc) ->
  Funclet.make().each ary, proc

module.exports = 
  start: start
  bind: bind
  map: map
  each: each


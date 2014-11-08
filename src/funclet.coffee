
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
    if proc.length == 1
      @calls.push (cb) ->
        try 
          proc cb 
        catch e
          cb e
    else
      @calls.push (res, cb) ->
        try 
          proc res, cb 
        catch e
          cb e
    @
  map: (ary, proc) ->
    @then (next) ->
      async.map ary, proc, next
  each: (ary, proc) ->
    @then (next) ->
      async.each ary, proc, next
  catch: (@onError) ->
    @
  done: (lastCB = () ->) ->
    self = @
    interim = []
    helper = (call, next) ->
      cb = (err, res...) ->
          loglet.debug 'funclet.done.helper.cb', err, interim
          if err 
            next err
          else 
            interim = res 
            next null 
      try 
        call interim..., cb
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

map = (ary, proc) ->
  Funclet.make().map ary, proc

each = (ary, proc) ->
  Funclet.make().each ary, proc

module.exports = 
  bind: bind
  map: map
  each: each


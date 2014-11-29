funclet = require '../src/funclet'
fs = require 'fs'
path = require 'path'
loglet = require 'loglet'
assert = require 'assert'

describe 'funclet test', ->
  
  it 'can chain together', (done) ->
    try 
      funclet
        .bind(fs.readFile, path.join(__dirname, '..', 'package.json'), 'utf8')
        .then (data, next) ->
          try 
            obj = JSON.parse(data)
            next null, obj
          catch e
            next e
        .catch(done)
        .done (obj) ->
          assert.equal obj.name, 'funclet'
          done null
    catch e
      done e
  
  it 'can auto catch errors in then', (done) ->
    try 
      funclet
        .bind(fs.readFile, path.join(__dirname, '..', 'README.md'), 'utf8')
        .then (data, next) ->
          obj = JSON.parse(data)
          next null, obj
        .catch (err) ->
          loglet.debug 'test.expect to catch this error', err
          done null
        .done (obj) ->
          done {error: 'not_expecting_to_JSON_parse_markdown_file', obj}
    catch e
      done e
  
  it 'can map', (done) ->
    try 
      funclet
        .map [1, 2, 3, 4], (i, next) ->
          next null, i * i
        .then (nums, next) ->
          res = 0 
          for num in nums
            res += num 
          next null, res 
        .catch(done)
        .done (num) ->
          assert.equal num, 30
          done null 
    catch e
      done e
  
  it 'can thenMap', (done) ->
    try
      funclet
        .bind (next) ->
          next null, [1,2,3,4]
        .thenMap (num, next) ->
          next null, num * num
        .then (nums, next) ->
          res = 0
          for num in nums
            res += num
          next null, res
        .catch(done)
        .done (num) ->
          assert.equal num, 30
          done null
    catch e
      done e
  
  it 'can each', (done) ->
    try 
      result = 0
      funclet
        .each [1, 2, 3, 4], (i, next) ->
          result += i * i
          next null
        .then (next) ->
          next null
        .catch(done)
        .done () ->
          assert.equal result, 30
          done null
    catch e
      done e
  
  it 'can thenEach', (done) ->
    try 
      result = 0
      funclet
        .bind (next) ->
          next null, [1,2,3,4]
        .thenEach (i, next) ->
          result += i * i
          next null
        .then (next) ->
          next null
        .catch(done)
        .done () ->
          assert.equal result, 30
          done null
    catch e
      done e
  
  it 'can pass multiple arguments', (done) ->
    try 
      funclet
        .bind (next) ->
          next null, 1, 2, 3, 4
        .then (a, b, c, d, next) ->
          loglet.debug 'arguments', arguments
          next null, a * a + b * b + c * c + d * d
        .catch(done)
        .done (num) ->
          assert.equal num, 30
          done null
    catch e
      done e
  
  it 'can use then as toplevel', (done) ->
    try
      funclet
        .start (next) ->
          next null, 1, 2, 3, 4
        .then (a, b, c, d, next) ->
          next null, a*a + b*b + c*c + d*d
        .catch(done)
        .done (num) ->
          assert.equal num, 30
          done null
    catch e
      done e



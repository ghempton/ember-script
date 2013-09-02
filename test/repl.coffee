suite 'REPL', ->

  Stream = require 'stream'

  MockInputStream = ->
    Stream.call(@)
    @
  MockInputStream.prototype = new Stream
  MockInputStream.prototype.readable = true
  MockInputStream.prototype.resume = ->
  MockInputStream.prototype.emitLine = (val) ->
    @emit 'data', new Buffer "#{val}\n"
  MockInputStream.prototype.constructor = MockInputStream

  MockOutputStream = ->
    Stream.call(@)
    @written = []
    @
  MockOutputStream.prototype = new Stream
  MockOutputStream.prototype.writable = true
  MockOutputStream.prototype.write = (data) ->
    @written.push data
  MockOutputStream.prototype.lastWrite = (fromEnd) ->
    @written[@written.length - 1 - fromEnd].replace /\n$/, ''
  MockOutputStream.prototype.cursorTo = ->
  MockOutputStream.prototype.clearLine = ->
  MockOutputStream.prototype.constructor = MockOutputStream

  historyFile = path.join __dirname, 'coffee_history_test'
  process.on 'exit', -> fs.unlinkSync historyFile

  input = null
  output = null
  repl = null

  beforeEach ->
    input = new MockInputStream
    output = new MockOutputStream
    repl = Repl.start {input, output, historyFile}

  afterEach ->
    repl.emit 'exit'

  ctrlV = { ctrl: true, name: 'v'}


  test 'starts with coffee prompt', ->
    eq 'coffee> ', output.lastWrite 0

  test 'writes eval to output', ->
    input.emitLine '1+1'
    eq '2', output.lastWrite 1

  test 'comments are ignored', ->
    input.emitLine '1 + 1 #foo'
    eq '2', output.lastWrite 1

  test 'output in inspect mode', ->
    input.emitLine '"1 + 1\\n"'
    eq "'1 + 1\\n'", output.lastWrite 1

  test "variables are saved", ->
    input.emitLine 'foo = "foo"'
    input.emitLine 'foobar = "#{foo}bar"'
    eq "'foobar'", output.lastWrite 1

  test 'empty command evaluates to undefined', ->
    input.emitLine ''
    eq 'coffee> ', output.lastWrite 0
    eq 'coffee> ', output.lastWrite 1

  test 'ctrl-v toggles multiline prompt', ->
    input.emit 'keypress', null, ctrlV
    eq '------> ', output.lastWrite 0
    input.emit 'keypress', null, ctrlV
    eq 'coffee> ', output.lastWrite 0

  test 'multiline continuation changes prompt', ->
    input.emit 'keypress', null, ctrlV
    input.emitLine ''
    eq '....... ', output.lastWrite 0

  test 'evaluates multiline', ->
    input.emit 'keypress', null, ctrlV
    input.emitLine 'do ->'
    input.emitLine '  1 + 1'
    input.emit 'keypress', null, ctrlV
    eq '2', output.lastWrite 1

  test 'variables in scope are preserved', ->
    input.emitLine 'a = 1'
    input.emitLine 'do -> a = 2'
    input.emitLine 'a'
    eq '2', output.lastWrite 1

  test 'existential assignment of previously declared variable', ->
    input.emitLine 'a = null'
    input.emitLine 'a ?= 42'
    eq '42', output.lastWrite 1

  test 'keeps running after runtime error', ->
    input.emitLine 'a = b'
    ok 0 <= (output.lastWrite 1).indexOf 'ReferenceError: b is not defined'
    input.emitLine 'a'
    ok 0 <= (output.lastWrite 1).indexOf 'ReferenceError: a is not defined'
    input.emitLine '0'
    eq '0', output.lastWrite 1

  test 'reads history from persistence file', ->
    input = new MockInputStream
    output = new MockOutputStream
    fs.writeFileSync historyFile, '0\n1\n'
    repl = Repl.start {input, output, historyFile}
    arrayEq ['1', '0'], repl.rli.history

  #test 'writes history to persistence file', ->
  #  fs.writeFileSync historyFile, ''
  #  input.emitLine '2'
  #  input.emitLine '3'
  #  eq '2\n3\n', (fs.readFileSync historyFile).toString()

  test '.history shows history', ->
    repl.rli.history = history = ['1', '2', '3']
    fs.writeFileSync historyFile, "#{history.join '\n'}\n"
    input.emitLine '.history'
    eq (history.reverse().join '\n'), output.lastWrite 1

  #test '.clear clears history', ->
  #  input = new MockInputStream
  #  output = new MockOutputStream
  #  fs.writeFileSync historyFile, ''
  #  repl = Repl.start {input, output, historyFile}
  #  input.emitLine '0'
  #  input.emitLine '1'
  #  eq '0\n1\n', (fs.readFileSync historyFile).toString()
  #  #arrayEq ['1', '0'], repl.rli.history
  #  input.emitLine '.clear'
  #  eq '.clear\n', (fs.readFileSync historyFile).toString()
  #  #arrayEq ['.clear'], repl.rli.history

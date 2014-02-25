
child_process = require 'child_process'
fs = require 'fs'
path = require 'path'

EmberScript = require './module'
{runModule} = require './run'

module.exports = not require.extensions['.em']?

require.extensions['.em'] = (module, filename) ->
  input = fs.readFileSync filename, 'utf8'
  csAst = EmberScript.parse input, raw: yes
  jsAst = EmberScript.compile csAst
  js = EmberScript.js jsAst
  runModule module, js, jsAst, filename

require.extensions['.litem'] = (module, filename) ->
  input = fs.readFileSync filename, 'utf8'
  csAst = EmberScript.parse input, raw: yes, literate: yes
  jsAst = EmberScript.compile csAst
  js = EmberScript.js jsAst
  runModule module, js, jsAst, filename

# patch child_process.fork to default to the em binary as the execPath for em/litem files
{fork} = child_process
unless fork.emPatched
  emBinary = path.resolve 'bin', 'ember-script'
  child_process.fork = (file, args = [], options = {}) ->
    if (path.extname file) in ['.em', '.litem', '.coffee', '.litcoffee']
      if not Array.isArray args
        args = []
        options = args or {}
      options.execPath or= emBinary
    fork file, args, options
  child_process.fork.emPatched = yes

delete require.cache[__filename]

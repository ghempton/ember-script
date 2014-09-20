EmberScript  = require './module'
CoffeeScript = require 'coffee-script'

LiveScript = require('LiveScript')

EmberScript.compileCode = (input, options) ->
  csAst = EmberScript.parse input, raw: yes
  jsAst = EmberScript.compile csAst
  EmberScript.js jsAst

compilers =
  js: (source) ->
    source

  coffee: (source) ->
    # console.log 'CoffeeScript.compile:', source
    CoffeeScript.compile source, { bare: true }

  live: (source) ->
    # console.log 'LivesScript.compile:', source
    LiveScript.compile source, { bare: true }

  ember: (source) ->
    # console.log 'EmberScript.compile:', source
    EmberScript.compileCode source, {raw: yes, literate: yes}

# emit the code to a file or stdout
# depending on options

createCodeEmitter = (options) ->
  (code) ->
    code = "#{code}\n"
    if options.output    
      fs.writeFile options.output, code, (err) ->
        throw err if err?
    else
      process.stdout.write code


multiCompile = require './multi-compiler'

module.exports = (code, options) ->
  mcOptions =
    lang: 'coffee'

  codeEmitter = options.codeEmitter || createCodeEmitter(options)
  multiCompile code, compilers, codeEmitter, mcOptions

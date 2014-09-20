fs = require 'fs'
CoffeeScript = require './module'
Repl = require './repl'
nopt = require 'nopt'
cscodegen = try require 'cscodegen'
escodegen = try require 'escodegen'
esmangle = try require 'esmangle'

inspect = (o) -> (require 'util').inspect o, no, 9e9, yes

knownOpts = {}
option = -> knownOpts[o] = Boolean for o in arguments; return
parameter = -> knownOpts[p] = String for p in arguments; return

optAliases =
  b: '--bare'
  c: '--compile'
  e: '--eval'
  f: '--cscodegen'
  I: '--require'
  i: '--input'
  j: '--js'
  l: '--literate'
  m: '--minify'
  o: '--output'
  p: '--parse'
  v: '--version'
  w: '--watch'

option 'parse', 'compile', 'optimise', 'debug', 'literate', 'raw', 'version', 'help'
parameter 'cli', 'input', 'nodejs', 'output', 'watch'

if escodegen?
  option 'bare', 'js', 'source-map', 'eval', 'repl'
  parameter 'source-map-file', 'require'
  if esmangle?
    option 'minify'

if cscodegen?
  option 'cscodegen'


options = nopt knownOpts, optAliases, process.argv, 2
positionalArgs = options.argv.remain
delete options.argv

# default values
options.optimise ?= yes

options.sourceMap = options['source-map']
options.sourceMapFile = options['source-map-file']

# make false to disable fragments
options.fragmented = true

# make false to disable multicompile (precedence over fragmented)
options.multiCompile = true

# input validation

unless options.compile or options.js or options.sourceMap or options.parse or options.eval or options.cscodegen
  if not escodegen?
    options.compile = on
  else if positionalArgs.length
    options.eval = on
    options.input = positionalArgs.shift()
    additionalArgs = positionalArgs
  else
    options.repl = on

# mutual exclusions
require('./cli-exclusions')(options)

# display CLI help 
require './cli-help' if options.help

if options.version
  pkg = require './../package.json'
  console.log "CoffeeScript version #{pkg.version}"

else if options.repl
  CoffeeScript.register()
  do process.argv.shift
  do Repl.start

else
  # normal workflow

  # choose input source

  inputSourceChooser = require './cli-input-source-chooser'
  inputSourceChooser.choose options

fs = require 'fs'
CoffeeScript = require './module'
{Preprocessor} = require './preprocessor'
{Optimiser} = require './optimiser'
{numberLines, humanReadable} = require './helpers'
{runMain} = require './run'
{concat, foldl} = require './functional-helpers'
cscodegen = try require 'cscodegen'
escodegen = try require 'escodegen'
esmangle = try require 'esmangle'

selectinputSource = (options) ->
  if options.input?
    fs.realpathSync options.input 
  else
    options.cli and '(cli)' or '(stdin)'

module.exports = (input, options, err) ->
  throw err if err?
  result = null
  inputName = options.input ? (options.cli and 'cli' or 'stdin')
  inputSource = selectinputSource options

  input = input.toString()
  # strip UTF BOM
  if 0xFEFF is input.charCodeAt 0 then input = input[1..]

  # preprocess
  if options.debug
    try
      console.error '### PREPROCESSED CS ###'
      preprocessed = Preprocessor.process input, literate: options.literate
      console.error numberLines humanReadable preprocessed

  # switch outputter if needed!
  if options.fragmented
    fragmenter = require('./cli-fragmenter')
    fragments = fragmenter(input)

    # console.log 'fragments', fragments
    options.parts =
      prepend: fragments.js

    output = require('./cli-output')(options)
    input = fragments.ember
  else
    output = require('./cli-output')('', options)

  # parse
  try
    result = CoffeeScript.parse input,
      optimise: no
      raw: options.raw or options.sourceMap or options.sourceMapFile or options.eval
      inputSource: inputSource
      literate: options.literate
  catch e
    console.error e.message
    process.exit 1
  if options.debug and options.optimise and result?
    console.error '### PARSED CS-AST ###'
    console.error inspect result.toBasicObject()

  # optimise
  if options.optimise and result?
    result = Optimiser.optimise result

  # --parse
  if options.parse
    if result?
      output inspect result.toBasicObject()
      return
    else
      process.exit 1

  if options.debug and result?
    console.error "### #{if options.optimise then 'OPTIMISED' else 'PARSED'} CS-AST ###"
    console.error inspect result.toBasicObject()

  # cs code gen
  if options.cscodegen
    try result = cscodegen.generate result
    catch e
      console.error (e.stack or e.message)
      process.exit 1
    if result?
      output result
      return
    else
      process.exit 1

  # compile
  jsAST = CoffeeScript.compile result, bare: options.bare

  # --compile
  if options.compile
    if jsAST?
      output inspect jsAST
      return
    else
      process.exit 1

  if options.debug and jsAST?
    console.error "### COMPILED JS-AST ###"
    console.error inspect jsAST

  # minification
  if options.minify
    try
      jsAST = esmangle.mangle (esmangle.optimize jsAST), destructive: yes
    catch e
      console.error (e.stack or e.message)
      process.exit 1

  if options.sourceMap
    # source map generation
    try sourceMap = CoffeeScript.sourceMap jsAST, inputName, compact: options.minify
    catch e
      console.error (e.stack or e.message)
      process.exit 1
    # --source-map
    if sourceMap?
      output "#{sourceMap}"
      return
    else
      process.exit 1

  # js code gen
  try
    {code: js, map: sourceMap} = CoffeeScript.jsWithSourceMap jsAST, inputName, compact: options.minify
  catch e
    console.error (e.stack or e.message)
    process.exit 1

  # --js
  if options.js
    if options.sourceMapFile
      fs.writeFileSync options.sourceMapFile, "#{sourceMap}"
      sourceMappingUrl =
        if options.output
          path.relative (path.dirname options.output), options.sourceMapFile
        else
          options.sourceMapFile
      js = """
        #{js}

        //# sourceMappingURL=#{sourceMappingUrl}
      """
    output js
    return

  # --eval
  if options.eval
    CoffeeScript.register()
    process.argv = [process.argv[1], options.input].concat additionalArgs
    runMain input, js, jsAST, inputSource
    return
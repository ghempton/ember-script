fs = require 'fs'

module.exports = (options) ->
  # mutual exclusions
  # - p (parse), c (compile), j (js), source-map, e (eval), cscodegen, repl
  if 1 isnt (options.parse ? 0) + (options.compile ? 0) + (options.js ? 0) + (options.sourceMap ? 0) + (options.eval ? 0) + (options.cscodegen ? 0) + (options.repl ? 0)
    console.error "Error: At most one of --parse (-p), --compile (-c), --js (-j), --source-map, --eval (-e), --cscodegen, or --repl may be used."
    process.exit 1

  # - i (input), w (watch), cli
  if 1 < options.input? + options.watch? + options.cli?
    console.error 'Error: At most one of --input (-i), --watch (-w), or --cli may be used.'
    process.exit 1

  # dependencies
  # - I (require) depends on e (eval)
  if options.require? and not options.eval
    console.error 'Error: --require (-I) depends on --eval (-e)'
    process.exit 1

  # - m (minify) depends on escodegen and esmangle and (c (compile) or e (eval))
  if options.minify and not (options.js or options.eval)
    console.error 'Error: --minify does not make sense without --js or --eval'
    process.exit 1

  # - b (bare) depends on escodegen and (c (compile) or e (eval)
  if options.bare and not (options.compile or options.js or options.sourceMap or options.eval)
    console.error 'Error: --bare does not make sense without --compile, --js, --source-map, or --eval'
    process.exit 1

  # - source-map-file depends on j (js)
  if options.sourceMapFile and not options.js
    console.error 'Error: --source-map-file depends on --js'
    process.exit 1

  # - i (input) depends on o (output) when input is a directory
  if options.input? and (fs.statSync options.input).isDirectory() and (not options.output? or (fs.statSync options.output)?.isFile())
    console.error 'Error: when --input is a directory, --output must be provided, and --output must not reference a file'
    process.exit 1

  # - cscodegen depends on cscodegen
  if options.cscodegen and not cscodegen?
    console.error 'Error: cscodegen must be installed to use --cscodegen'
    process.exit 1
fs = require 'fs'

comments =
  prepend: 'Prepended by emberscript code fragmentation'
  append:  'Appended by emberscript code fragmentation'

comment = (msg) ->
  '// '.concat(comments.prepend).concat '\n'

codeFor = (parts, name) ->
  comment(comments[name]).concat parts[name]

mergeParts = (out, parts) ->
  return out unless typeof parts is 'object'
  if parts.prepend
    prepend = codeFor parts, 'prepend'
    out = prepend.concat out

  if parts.append
    append = codeFor parts, 'append'
    out = out.concat append
  out

outCode =
  basic: (out) ->
    "#{out}\n"

  fragmented: (out, parts) ->
    out = outCode.basic out
    out = mergeParts(out, parts) if parts
    out

module.exports = (options) ->
    outEmitter = if options.fragmented then outCode.fragmented else outCode.basic

    (out) ->
      # --output

      # do any last-minute prepend/append (or other magic) here!
      outCode = outEmitter out, options.parts

      # console.log 'outCode', outCode

      if options.output    
        fs.writeFile options.output, outCode, (err) ->
          throw err if err?
      else
        process.stdout.write outCode

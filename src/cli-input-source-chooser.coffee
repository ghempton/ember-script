fs = require 'fs'

module.exports = {
  choose: (options) ->
    input = ''  

    processInput = require './cli-process-input'

    if options.input?
      fs.stat options.input, (err, stats) ->
        throw err if err?
        if stats.isDirectory()
          options.input = path.join options.input, 'index.coffee'
        fs.readFile options.input, (err, contents) ->
          throw err if err?
          input = contents
          processInput input, options
    else if options.watch?
      options.watch # TODO: watch
    else if options.cli?
      input = options.cli
      processInput input, options
    else
      process.stdin.on 'data', (data) -> input += data
      process.stdin.on 'end', processInput
      process.stdin.setEncoding 'utf8'
      do process.stdin.resume  
}

